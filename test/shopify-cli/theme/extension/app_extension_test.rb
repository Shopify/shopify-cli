# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/extension/dev_server"

module ShopifyCLI
  module Theme
    module Extension
      class AppExtensionTest < Minitest::Test
        def setup
          super
          @extension = AppExtension.new(ctx, root: root, id: 1234)
        end

        def test_extension_files_include_only_extension_directory
          files = @extension.extension_files

          files.each do |file|
            # confirm all extension files are in blocks/ or assets/
            assert_match(/blocks\/|assets\//, file.relative_path)
          end
        end

        def test_extension_files_contains_no_duplicates
          files = @extension.extension_files

          assert_equal files, files.uniq
        end

        def test_extension_file_only_matches_file_in_root
          assert @extension.extension_file?("#{ShopifyCLI::ROOT}/test/fixtures/extension/blocks/block1.liquid")
          assert @extension.extension_file?("#{ShopifyCLI::ROOT}/test/fixtures/extension/assets/block1.css")
          assert @extension.extension_file?("#{ShopifyCLI::ROOT}/test/fixtures/extension/assets/block1.js")
          refute @extension.extension_file?("#{ShopifyCLI::ROOT}/test/fixtures/theme/sections/footer.liquid")
          refute @extension.extension_file?("#{ShopifyCLI::ROOT}/test/fixtures/api/versions.json")
        end

        private

        def root
          "#{ShopifyCLI::ROOT}/test/fixtures/extension"
        end

        def ctx
          ShopifyCLI::Context.new
        end
      end
    end
  end
end
