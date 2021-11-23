require "test_helper"

module ShopifyCLI
  module Tasks
    class EnsureAuthenticatedTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
      end

      def test_call_when_not_authenticated_raises_an_error
        # Given
        ShopifyCLI::IdentityAuth.expects(:authenticated?).returns(false)
        expected_error_message = "Please ensure you've logged in with {{command:shopify login}} and try again"

        # Then
        assert_raises ShopifyCLI::Abort, expected_error_message do
          EnsureAuthenticated.call(@context)
        end
      end

      def test_call_when_authenticated_with_token_informs_the_user
        # Given
        ShopifyCLI::IdentityAuth.expects(:authenticated?).returns(true)
        ShopifyCLI::IdentityAuth.expects(:environment_auth_token?).returns(true)
        expected_message = "SHOPIFY_CLI_AUTH_TOKEN environment variable. We'll authenticate using its value as a token."
        @context.expects(:puts).with(expected_message)

        # Then
        EnsureAuthenticated.call(@context)
      end
    end
  end
end
