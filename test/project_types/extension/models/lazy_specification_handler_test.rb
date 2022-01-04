# typed: ignore
require "test_helper"

module Extension
  module Models
    class LazySpecificationHandlerTest < MiniTest::Test
      def setup
        ShopifyCLI::ProjectType.load_type(:extension)
        super
      end

      def test_accessing_the_identifier_does_not_result_in_delegatee_resolution
        delegatee_resolved = false
        handler = LazySpecificationHandler.new("test-extension") do
          delegatee_resolved = true
        end
        assert_equal "test-extension", handler.identifier
        refute delegatee_resolved
      end
    end
  end
end
