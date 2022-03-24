require "net/http"
require "fileutils"
require "shopify_cli/sed"
require "shopify_cli/changelog"
require "octokit"

module ShopifyCLI
  class Release
    def initialize(new_version, github_access_token)
      @new_version = new_version
      @changelog = ShopifyCLI::Changelog.new
      @github = Octokit::Client.new(access_token: github_access_token)
    end

    def prepare!
      ensure_updated_main
      create_release_branch
      update_changelog
      update_versions_in_files
      commit
      pr = create_pr
      system("open #{pr["html_url"]}")
    end

    def package!
      ensure_updated_main
      ensure_correct_gem_version
      Rake::Task["package"].invoke
      update_homebrew
      create_github_release
    end

    private

    attr_reader :new_version, :changelog, :github

    def ensure_updated_main
      current_branch = %x(git branch --show-current)
      unless current_branch == "main"
        raise "Must be on the main branch to perform this operation. First run `git checkout main`"
      end
      unless system("git pull")
        raise "git pull failed, cannot be sure there aren't new commits!"
      end
    end

    def create_release_branch
      puts "Checking out release branch"
      unless system("git checkout -b #{release_branch_name}")
        puts "Cannot check out release branch!"
      end
    end

    def update_changelog
      if release_notes("Unreleased").empty?
        puts "No unreleased CHANGELOG updates found!"
      else
        puts "Updating CHANGELOG"
        changelog.update_version!(new_version)
      end
    end

    def update_versions_in_files
      version_file = File.join(ShopifyCLI::ROOT, "lib/shopify_cli/version.rb")
      puts "Updating version.rb"
      ShopifyCLI::Sed.new.replace_inline(version_file, ShopifyCLI::VERSION, new_version)
      gemfile_lock = File.join(ShopifyCLI::ROOT, "Gemfile.lock")
      puts "Updating Gemfile.lock"
      ShopifyCLI::Sed.new.replace_inline(
        gemfile_lock,
        "shopify-cli (#{ShopifyCLI::VERSION})",
        "shopify-cli (#{new_version})",
      )
    end

    def commit
      puts "Committing"
      unless system("git commit -am 'Packaging for release v#{new_version}'")
        raise "Commit failed!"
      end
      unless system("git push -u origin #{release_branch_name}")
        raise "Failed to push branch!"
      end
    end

    def create_pr
      repo = "Shopify/shopify-cli"
      github.create_pull_request(
        repo,
        "main",
        release_branch_name,
        "Packaging for release v#{new_version}",
        release_notes("Unreleased")
      ).tap { |results| puts "Created #{repo} PR ##{results["number"]}" }
    end

    def ensure_correct_gem_version
      response = Net::HTTP.get(URI("https://rubygems.org/api/v1/versions/shopify-cli/latest.json"))
      latest_version = JSON.parse(response)["version"]
      unless latest_version == new_version
        raise "Attempted to update to #{new_version}, but latest on RubyGems is #{latest_version}"
      end
    end

    def update_homebrew
      ensure_updated_homebrew_repo
      update_homebrew_repo
      pr = create_homebrew_pr
      system("open #{pr["html_url"]}")
    end

    def ensure_updated_homebrew_repo
      unless File.exist?(homebrew_path)
        unless system("/opt/dev/bin/dev clone homebrew-shopify")
          raise "Failed to clone homebrew-shopify repo!"
        end
      end

      Dir.chdir(homebrew_path) do
        unless system("git checkout master && git pull")
          raise "Failed to pull latest homebrew-shopify!"
        end
        system("git checkout -b #{homebrew_release_branch}")
      end
    end

    def update_homebrew_repo
      source_file = File.join(package_dir, "shopify-cli.rb")
      FileUtils.copy(source_file, homebrew_path)
      message = "Update Shopify CLI to #{new_version}"
      Dir.chdir(homebrew_path) do
        unless system("git commit -am '#{homebrew_update_message}'")
          raise "Commit failed!"
        end
        unless system("git push -u origin #{homebrew_release_branch}")
          raise "Failed to push branch!"
        end
      end
    end

    def create_homebrew_pr
      repo = "Shopify/homebrew-shopify"
      github.create_pull_request(
        repo,
        "master",
        homebrew_release_branch,
        homebrew_update_message,
        homebrew_release_notes
      ).tap { |results| puts "Created #{repo} PR ##{results["number"]}" }
    end

    def create_github_release
      release = github.create_release(
        "Shopify/shopify-cli",
        "v#{new_version}",
        {
          name: "Version #{new_version}",
          body: release_notes(new_version)
        }
      )
      %w(.deb -1.noarch.rpm).each do |suffix|
        github.upload_asset(
          release["url"],
          File.join(package_dir, "shopify-cli-#{new_version}#{suffix}")
        )
      end
      system("open #{release["html_url"]}")
    end

    def homebrew_path
      @homebrew_path ||= `/opt/dev/bin/dev project-path homebrew-shopify`.chomp
    end

    def homebrew_update_message
      @homebrew_update_message ||= "Update Shopify CLI to #{new_version}"
    end

    def package_dir
      @package_dir ||= File.join(ShopifyCLI::ROOT, "packaging", "builds", new_version)
    end

    def homebrew_release_branch
      "release_#{new_version.split(".").join("_")}_of_shopify-cli"
    end

    def homebrew_release_notes
      "I'm releasing a new version of the Shopify CLI, " \
        "[#{new_version}](https://github.com/Shopify/shopify-cli/releases/tag/v#{new_version})"
    end

    def release_branch_name
      @release_branch_name ||= "release_#{new_version.split(".").join("_")}"
    end

    def release_notes(version)
      changelog.release_notes(version)
    end
  end
end
