# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/extension/syncer/operation"

module ShopifyCLI
  module Theme
    module Extension
      class Syncer
        class OperationTest < Minitest::Test
          def test_delete?
            operation1 = Operation.new(nil, :delete)
            operation2 = Operation.new(nil, :something)

            assert(operation1.delete?)
            refute(operation2.delete?)
          end

          def test_create?
            operation1 = Operation.new(nil, :create)
            operation2 = Operation.new(nil, :something)

            assert(operation1.create?)
            refute(operation2.create?)
          end
        end
      end
    end
  end
end
