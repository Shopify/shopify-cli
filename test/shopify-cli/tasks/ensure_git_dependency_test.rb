require "test_helper"

module ShopifyCLI
  module Tasks
    class EnsureGitDependencyTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
      end

      def test_call_when_no_git_raises_an_error
        # Given
        ShopifyCLI::Git.expects(:available?).with(@context).returns(false)
        expected_error_message = "Please install git"

        # Then
        assert_raises ShopifyCLI::Abort, expected_error_message do
          EnsureGitDependency.call(@context)
        end
      end

      def test_call_when_git_exists_remains_silent
        # Given
        ShopifyCLI::Git.expects(:available?).with(@context).returns(true)
        @context.expects(:puts).never

        # Then
        EnsureGitDependency.call(@context)
      end
    end
  end
end
