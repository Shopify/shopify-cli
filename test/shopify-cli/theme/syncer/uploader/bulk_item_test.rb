# frozen_string_literal: true

require "test_helper"

require "shopify_cli/theme/theme"
require "shopify_cli/theme/syncer/uploader/bulk_item"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class BulkItemTest < Minitest::Test
          def setup
            super

            root = ShopifyCLI::ROOT + "/test/fixtures/theme"

            @theme = Theme.new(@ctx, id: 1, root: root)
            @file = @theme["config/settings_data.json"]
            @bulk_item = BulkItem.new(@file)
          end

          def test_to_h
            expected = {
              body: "{\"asset\":{\"key\":\"config/settings_data.json\",\"value\":\"{}\\n\"}}",
            }
            actual = @bulk_item.to_h

            assert_equal(expected, actual)
          end

          def test_to_s
            expected = "#<ShopifyCLI::Theme::Syncer::Uploader::BulkItem key=config/settings_data.json, retries=0>"
            actual = @bulk_item.to_s

            assert_equal(expected, actual)
          end

          def test_key
            expected = "config/settings_data.json"
            actual = @bulk_item.key

            assert_equal(expected, actual)
          end

          def test_liquid_when_file_is_a_liquid_template
            key = "sections/footer.liquid"
            bulk_item = BulkItem.new(@theme[key])

            assert(bulk_item.liquid?)
          end

          def test_liquid_when_file_is_a_json_file
            key = "config/settings_data.json"
            bulk_item = BulkItem.new(@theme[key])

            refute(bulk_item.liquid?)
          end
        end
      end
    end
  end
end
