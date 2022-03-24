require "shopify_cli/sed"

module ShopifyCLI
  class Changelog
    CHANGELOG_FILE = File.join(ShopifyCLI::ROOT, "CHANGELOG.md")

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

    def release_notes(version)
      changes[version].map do |change_category, changes|
        <<~CHANGES
          ### #{change_category}
          #{changes.map { |change| entry(**change) }.join("\n")}
        CHANGES
      end.join("\n")
    end

    def entry(pr_id:, desc:)
      "* [##{pr_id}](https://github.com/Shopify/shopify-cli/pull/#{pr_id}): #{desc}"
    end

    private

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
      @remainder = ""
      log.each_line do |line|
        case state
        when :initial
          next unless line.chomp == "\#\# [Unreleased]"
          state = :unreleased
          current_version = "Unreleased"
        when :unreleased, :last_version
          if /\A\#\#\# (?<category>\w+)/ =~ line
            change_category = category
          elsif %r{\A\* \[\#(?<pr_id>\d+)\]\(https://github.com/Shopify/shopify-cli/pull/\d+\): (?<desc>.+)\n} =~ line
            changes[current_version][change_category] << { pr_id: pr_id, desc: desc }
          elsif /\A\#\# Version (?<version>\d+\.\d+\.\d+)/ =~ line
            current_version = version
            state =
              case state
              when :unreleased
                :last_version
              else
                :finished
              end
          elsif !line.match?(/\s*\n/)
            raise "Unrecognized line: #{line.inspect}"
          end
        when :finished
          @remainder << line
        end
      end
    end
  end
end
