# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/merger"

module ShopifyCLI
  module Theme
    class Syncer
      class MergerTest < Minitest::Test
        def test_union_merge
          file = theme_file(<<-CONTENT)
            {
              "name":"SHOPIFY CLI",
              "version":"2",
              "type":"tool"
            }
          CONTENT
          new_content = <<-CONTENT
            {
              "name":"SHOPIFY CLI",
              "version":"3",
              "uuid":"0000-1111-2222-3333",
              "type":"tool"
            }
          CONTENT
          expected_content = <<-CONTENT
            {
              "name":"SHOPIFY CLI",
              "version":"2",
              "version":"3",
              "uuid":"0000-1111-2222-3333",
              "type":"tool"
            }
          CONTENT
          actual_content = Merger.union_merge(file, new_content)

          assert_equal(expected_content, actual_content)
        ensure
          file.fs_file.close!
        end

        private

        def theme_file(content)
          file = Tempfile.new("theme_file")
          file.write(content)
          file.close

          stub(
            name: "theme_file",
            absolute_path: file.path,
            fs_file: file
          )
        end
      end
    end
  end
end
