# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/uploader/forms/select_update_strategy"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        module Forms
          class SelectUpdateStrategyTest < Minitest::Test
            def setup
              super
              @form = SelectUpdateStrategy.new(@context, [], {})
            end

            def test_strategies
              refute_empty(@form.strategies)
            end

            def test_prefix
              refute_empty(@form.prefix)
            end
          end
        end
      end
    end
  end
end
