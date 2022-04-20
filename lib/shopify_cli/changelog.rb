require "date"
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
      changes[new_version] = changes["Unreleased"]
      changes[new_version][:date] = Date.today.iso8601
      changes["Unreleased"] = { changes: [], date: nil }
      save!
    end

    def update!
      pr = pr_for_current_branch
      category = CLI::UI::Prompt.ask("What type of change?", options: CHANGE_CATEGORIES)
      add_change(category, { pr_id: pr.number, desc: pr.title })
      save!
    end

    def release_notes(version)
      changes[version][:changes].map do |change_category, changes|
        <<~CHANGES
          ### #{change_category}
          #{changes.map { |change| entry(**change) }.join("\n")}
        CHANGES
      end.join("\n")
    end

    def add_change(category, change)
      changes["Unreleased"][:changes][category] << change
    end

    def entry(pr_id:, desc:)
      "* [##{pr_id}](https://github.com/Shopify/shopify-cli/pull/#{pr_id}): #{desc}"
    end

    def full_contents
      sorted_changes = changes.each_key.sort_by do |change|
        if change == "Unreleased"
          [Float::INFINITY] * 3 # end of the list
        else
          major, minor, patch = change.split(".").map(&:to_i)
          [major, minor, patch]
        end
      end.reverse
      [
        heading,
        *sorted_changes.each.map { |version| release_notes_with_header(version) }.join,
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
          date = changes[version][:date]
          "Version #{version}#{" - #{date}" if date}"
        end

      [
        "## #{header_line}",
        release_notes(version),
      ].reject(&:empty?).map { |section| section.chomp << "\n\n" }.join
    end

    def changes
      @changes ||= Hash.new do |h, k|
        h[k] = {
          date: nil,
          changes: Hash.new do |h2, k2|
            h2[k2] = []
          end,
        }
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
            # Ensure Unreleased changeset exists even if no changes have happened yet
            changes["Unreleased"]
          else
            @heading << line
          end
        when :unreleased, :prior_versions
          if /\A\#\#\# (?<category>\w+)/ =~ line
            change_category = category
          elsif %r{\A\* \[\#(?<id>\d+)\]\(https://github.com/Shopify/shopify-cli/pull/\k<id>\): (?<desc>.+)\n} =~ line
            changes[current_version][:changes][change_category] << { pr_id: id, desc: desc }
          elsif /\A\#\# Version (?<version>\d+\.\d+\.\d+)( - (?<date>\d{4}-\d{2}-\d{2}))?/ =~ line
            current_version = version
            state = :prior_versions
            major, minor, _patch = current_version.split(".")
            if major.to_i <= 2 && minor.to_i < 7
              # Changelog starts to become irregular in 2.6.x
              state = :finished
            end
            changes[current_version][:date] = date unless state == :finished
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
