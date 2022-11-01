require "net/http"
require "fileutils"
require "shopify_cli/sed"
require "shopify_cli/changelog"
require "octokit"

module ShopifyCLI
  class Release
    def initialize(new_version, github_access_token)
      @new_version = new_version
      @github = Octokit::Client.new(access_token: github_access_token)
    end

    def prepare!
      ensure_updated_main
      create_release_branch
      update_changelog
      update_versions_in_files
      commit_packaging
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

    attr_reader :new_version, :github

    def ensure_updated_main
      # We can't be sure what is the correct action to take if changes have been
      # made but not committed. Ensure the user handles the situation before
      # moving on.
      unless %x(git status --porcelain).empty?
        raise <<~MESSAGE
          Uncommitted changes have been made to the repository.
          Please make sure `git status` does not show any changes before continuing.
        MESSAGE
      end
      system_or_fail("git checkout main", "check out main branch")
      unless system("git pull")
        raise "git pull failed, cannot be sure there aren't new commits!"
      end
    end

    def create_release_branch
      puts "Checking out release branch"
      system_or_fail("git checkout -b #{release_branch_name}", "check out release branch")
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

    def commit_packaging
      puts "Committing"
      system_or_fail("git commit -am 'Packaging for release v#{new_version}'", "commit")
      system_or_fail("git push -u origin #{release_branch_name}", "push branch")
    end

    def create_pr
      repo = "Shopify/shopify-cli"
      github.create_pull_request(
        repo,
        "main",
        release_branch_name,
        "Packaging for release v#{new_version}",
        release_notes(new_version)
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
        system_or_fail("/opt/dev/bin/dev clone homebrew-shopify", "clone homebrew-shopify repo")
      end

      Dir.chdir(homebrew_path) do
        system_or_fail("git checkout master && git pull", "pull latest homebrew-shopify")
        system_or_fail("git checkout -b #{homebrew_release_branch}", "check out homebrew branch")
      end
    end

    def update_homebrew_repo
      source_file = File.join(package_dir, "shopify-cli@2.rb")
      FileUtils.copy(source_file, homebrew_path)
      Dir.chdir(homebrew_path) do
        system_or_fail("git commit -am '#{homebrew_update_message}'", "commit homebrew update")
        system_or_fail("git push -u origin #{homebrew_release_branch}", "push homebrew branch")
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
          body: release_notes(new_version),
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
      @homebrew_path ||= %x(/opt/dev/bin/dev project-path homebrew-shopify).chomp
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

    def system_or_fail(command, action)
      raise "Failed to #{action}!" unless system(command)
    end

    def changelog
      @changelog ||= ShopifyCLI::Changelog.new
    end
  end
end
