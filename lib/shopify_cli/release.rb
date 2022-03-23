require 'shopify_cli/sed'
require 'shopify_cli/changelog'
require 'octokit'

module ShopifyCLI
  class Release
    def initialize(new_version, github_access_token)
      @new_version = new_version
      @changelog = ShopifyCLI::Changelog.new
      @github = Octokit::Client.new(access_token: github_access_token)
    end

    def create!
      #ensure_updated_main
      create_release_branch
      update_changelog
      update_versions_in_files
      commit
      pr = create_pr
      system("open #{pr["html_url"]}")
    end

    private

    attr_reader :new_version, :changelog, :github

    def ensure_updated_main
      current_branch = `git branch --show-current`
      unless current_branch == "main"
        raise "Must be on the main branch to package a release!"
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
      if release_notes.empty?
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
        puts "Commit failed!"
      end
      unless system("git push -u origin #{release_branch_name}")
        puts "Failed to push branch!"
      end
    end

    def create_pr
      github.create_pull_request(
        "Shopify/shopify-cli",
        "main",
        release_branch_name,
        "Packaging for release v#{new_version}",
        release_notes
      ).tap { |results| puts "Created PR ##{results["number"]}" }
    end

    def release_branch_name
      @release_branch_name ||= "release_#{new_version.split('.').join('_')}"
    end

    def release_notes
      @release_notes ||= changelog.release_notes("Unreleased")
    end
  end
end
