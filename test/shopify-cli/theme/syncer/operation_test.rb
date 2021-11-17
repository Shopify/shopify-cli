# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer"

module ShopifyCLI
  module Theme
    class Syncer
      class OperationTest < Minitest::Test
        def test_to_s
          file = stub(relative_path: "sections/apps.liquid")
          operation = Operation.new("update", file)

          assert_equal("update sections/apps.liquid", operation.to_s)
        end

        def test_to_s_when_file_is_nil
          operation = Operation.new("update", nil)

          assert_equal("update ", operation.to_s)
        end
      end
    end
  end
end
