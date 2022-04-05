# frozen_string_literal: true

require "tempfile"

module ShopifyCLI
  module Theme
    class Syncer
      class Merger
        class << self
          ##
          # Merge `theme_file` with the `new_content` by relying on the union merge
          #
          def union_merge(theme_file, new_content)
            git_merge(theme_file, new_content, ["--union", "-p"])
          end

          private

          ##
          # Merge theme file (`ShopifyCLI::Theme::File`) with a new content (String),
          # by creating a temporary file based on the `new_content`.
          #
          def git_merge(theme_file, new_content, opts)
            remote_file = create_tmp_file(tmp_file_name(theme_file), new_content)
            empty_file = create_tmp_file("empty")

            ShopifyCLI::Git.merge_file(
              theme_file.absolute_path,
              empty_file.path,
              remote_file.path,
              opts
            )
          ensure
            # Remove temporary files on Windows as well
            remote_file.close!
            empty_file.close!
          end

          def create_tmp_file(basename, content = "")
            tmp_file = Tempfile.new(basename)
            tmp_file.write(content)
            tmp_file.close # Make it ready to merge
            tmp_file
          end

          def tmp_file_name(ref_file)
            "shopify-cli-merge-#{ref_file.name(".*")}"
          end
        end
      end
    end
  end
end
