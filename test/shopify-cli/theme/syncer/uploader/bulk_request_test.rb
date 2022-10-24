# frozen_string_literal: true

require "test_helper"

require "shopify_cli/theme/theme"
require "shopify_cli/theme/syncer/uploader/bulk_item"
require "shopify_cli/theme/syncer/uploader/bulk_request"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class BulkRequestTest < Minitest::Test
          def setup
            super

            root = ShopifyCLI::ROOT + "/test/fixtures/theme"

            theme = Theme.new(@ctx, id: 1, root: root)
            bulk_items = [
              BulkItem.new(theme["config/settings_data.json"]),
              BulkItem.new(theme["sections/footer.liquid"]),
            ]

            @bulk_request = BulkRequest.new(theme, bulk_items)
          end

          def test_to_h
            actual = @bulk_request.to_h
            expected = {
              path: "themes/1/assets/bulk.json",
              method: "PUT",
              body: JSON.generate({
                assets: [
                  { key: "config/settings_data.json", value: "{}\n" },
                  { key: "sections/footer.liquid", value: "" },
                ],
              }),
            }
            assert_equal(expected, actual)
          end

          private

          def theme
            @theme ||= Theme.new(ctx, root: root, id: "123")
          end

          def ctx
            @ctx ||= TestHelpers::FakeContext.new(root: root)
          end

          def root
            ShopifyCLI::ROOT + "/test/fixtures/theme"
          end
        end
      end
    end
  end
end
