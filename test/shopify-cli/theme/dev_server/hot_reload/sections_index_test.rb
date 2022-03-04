# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server/hot_reload/sections_index"
require "shopify_cli/theme/theme"

module ShopifyCLI
  module Theme
    module DevServer
      class HotReload
        class SectionsIndexTest < Minitest::Test
          def setup
            super
            root = ShopifyCLI::ROOT + "/test/fixtures/theme"
            @theme = Theme.new(nil, root: root)
          end

          def test_section_names_by_type
            expected_index = { "main-blog" => ["main"] }
            actual_index = SectionsIndex.new(@theme).section_names_by_type

            assert_equal(expected_index, actual_index)
          end
        end
      end
    end
  end
end
