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
        ShopifyCLI::Git.expects(:exists?).with(@context).returns(false)

        # Then
        error = assert_raises ShopifyCLI::Abort do
          EnsureGitDependency.call(@context)
        end
        assert_equal(@context.message("core.git.error.nonexistent"), error.message)
      end

      def test_call_when_git_exists_remains_silent
        # Given
        ShopifyCLI::Git.expects(:exists?).with(@context).returns(true)
        @context.expects(:puts).never

        # Then
        EnsureGitDependency.call(@context)
      end
    end
  end
end
