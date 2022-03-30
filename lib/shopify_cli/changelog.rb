require "shopify_cli/sed"
require "octokit"

module ShopifyCLI
  class Changelog
    CHANGELOG_FILE = File.join(ShopifyCLI::ROOT, "CHANGELOG.md")
    CHANGE_CATEGORIES = %w(Added Changed Deprecated Removed Fixed Security)

    def initialize
      load(File.read(CHANGELOG_FILE))
    end

    def update_version!(new_version)
      Sed.new.replace_inline(
        CHANGELOG_FILE,
        "## \\[Unreleased\\]",
        "## [Unreleased]\\n\\n## Version #{new_version}"
      )
    end

    def update!
      pr = pr_for_current_branch
      category = CLI::UI::Prompt.ask("What type of change?", options: CHANGE_CATEGORIES)
      add_change(category, { pr_id: pr.number, desc: pr.title })
      save!
    end

    def release_notes(version)
      changes[version].map do |change_category, changes|
        <<~CHANGES
          ### #{change_category}
          #{changes.map { |change| entry(**change) }.join("\n")}
        CHANGES
      end.join("\n")
    end

    def add_change(category, change)
      changes["Unreleased"][category] << change
    end

    def entry(pr_id:, desc:)
      "* [##{pr_id}](https://github.com/Shopify/shopify-cli/pull/#{pr_id}): #{desc}"
    end

    def full_contents
      [
        heading,
        *changes.each_key.map { |version| release_notes_with_header(version) }.join,
        remainder,
      ].map { |section| section.chomp << "\n" }.join
    end

    def save!
      File.write(CHANGELOG_FILE, full_contents)
    end

    private

    attr_reader :heading, :remainder

    def release_notes_with_header(version)
      header_line =
        if version == "Unreleased"
          "[Unreleased]"
        else
          "Version #{version}"
        end

      [
        "## #{header_line}",
        release_notes(version),
      ].reject(&:empty?).map { |section| section.chomp << "\n\n" }.join
    end

    def changes
      @changes ||= Hash.new do |h, k|
        h[k] = Hash.new do |h2, k2|
          h2[k2] = []
        end
      end
    end

    def load(log)
      state = :initial
      change_category = nil
      current_version = nil
      @heading = ""
      @remainder = ""
      log.each_line do |line|
        case state
        when :initial
          if line.chomp == "\#\# [Unreleased]"
            state = :unreleased
            current_version = "Unreleased"
          else
            @heading << line
          end
        when :unreleased, :prior_versions
          if /\A\#\#\# (?<category>\w+)/ =~ line
            change_category = category
          elsif %r{\A\* \[\#(?<id>\d+)\]\(https://github.com/Shopify/shopify-cli/pull/\k<id>\): (?<desc>.+)\n} =~ line
            changes[current_version][change_category] << { pr_id: id, desc: desc }
          elsif /\A\#\# Version (?<version>\d+\.\d+\.\d+)/ =~ line
            current_version = version
            if state == :unreleased
              state = :prior_versions
            else
              major, minor, patch = current_version.split(".")
              # Changelog starts to become irregular in 2.6.x
              if major.to_i <= 2 && minor.to_i < 7
                state = :finished
              end
            end
          elsif !line.match?(/\s*\n/)
            raise "Unrecognized line: #{line.inspect}"
          end
        end
        @remainder << line if state == :finished
      end
    end

    def pr_for_current_branch
      current_branch = %x(git branch --show-current).chomp
      search_term = "repo:Shopify/shopify-cli is:pr is:open head:#{current_branch}"
      results = Octokit::Client.new.search_issues(search_term)
      case results.total_count
      when 0
        raise "PR not opened yet!"
      when (2..)
        raise "Multiple open PRs, not sure which one to use for changelog!"
      end

      results.items.first
    end
  end
end
