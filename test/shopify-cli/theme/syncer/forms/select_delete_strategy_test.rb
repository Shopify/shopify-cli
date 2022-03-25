# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/forms/select_delete_strategy"

module ShopifyCLI
  module Theme
    class Syncer
      module Forms
        class SelectDeleteStrategyTest < Minitest::Test
          def setup
            super
            @form = SelectDeleteStrategy.new(@context, [], {})
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
