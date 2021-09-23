require "test_helper"

module ShopifyCLI
  module Tasks
    class EnsureProjectTypeTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
      end

      def test_returns_true_if_in_proper_project_type
        ShopifyCLI::Project.expects(:current_project_type).returns(:rails)
        assert EnsureProjectType.call(@context, "rails")
      end

      def test_aborts_if_in_invalid_project_type
        ShopifyCLI::Project.expects(:current_project_type).returns(nil)
        exception = assert_raises ShopifyCLI::Abort do
          EnsureProjectType.call(@context, "rails")
        end
        assert_includes exception.message, @context.message(
          "core.tasks.ensure_project_type.wrong_project_type", "rails"
        )
      end
    end
  end
end
