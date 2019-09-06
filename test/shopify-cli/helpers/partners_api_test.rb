require 'test_helper'

module ShopifyCli
  module Helpers
    class PartnersAPITest < MiniTest::Test
      include TestHelpers::Project

      def setup
        super
        Helpers::PkceToken.stubs(:read).returns('token123')
      end

      def test_id
        ENV['SHOPIFY_APP_CLI_LOCAL_PARTNERS'] = '1'
        assert_equal PartnersAPI::DEV_ID, PartnersAPI.id
        ENV.delete('SHOPIFY_APP_CLI_LOCAL_PARTNERS')
        assert_equal PartnersAPI::PROD_ID, PartnersAPI.id
      end

      def test_cli_id
        ENV['SHOPIFY_APP_CLI_LOCAL_PARTNERS'] = '1'
        assert_equal PartnersAPI::DEV_CLI_ID, PartnersAPI.cli_id
        ENV.delete('SHOPIFY_APP_CLI_LOCAL_PARTNERS')
        assert_equal PartnersAPI::PROD_CLI_ID, PartnersAPI.cli_id
      end

      def test_auth_endpoint
        ENV['SHOPIFY_APP_CLI_LOCAL_PARTNERS'] = '1'
        assert_equal PartnersAPI::AUTH_DEV_URI, PartnersAPI.auth_endpoint
        ENV.delete('SHOPIFY_APP_CLI_LOCAL_PARTNERS')
        assert_equal PartnersAPI::AUTH_PROD_URI, PartnersAPI.auth_endpoint
      end

      def test_endpoint
        ENV['SHOPIFY_APP_CLI_LOCAL_PARTNERS'] = '1'
        assert_equal PartnersAPI::DEV_URI, PartnersAPI.endpoint
        ENV.delete('SHOPIFY_APP_CLI_LOCAL_PARTNERS')
        assert_equal PartnersAPI::PROD_URI, PartnersAPI.endpoint
      end

      def test_query_calls_partners_api
        api_stub = Object.new
        PartnersAPI.expects(:new).with(
          ctx: @context,
          token: 'token123',
          url: "#{PartnersAPI.endpoint}/api/cli/graphql",
        ).returns(api_stub)
        api_stub.expects(:query).with('query', variables: {}).returns('response')
        assert_equal 'response', PartnersAPI.query(@context, 'query')
      end

      def test_query_can_reauth
        api_stub = Object.new
        PartnersAPI.expects(:new).with(
          ctx: @context,
          token: 'token123',
          url: "#{PartnersAPI.endpoint}/api/cli/graphql",
        ).returns(api_stub).twice
        api_stub.expects(:query).with('query', variables: {}).returns('response')
        api_stub.expects(:query).raises(API::APIRequestUnauthorizedError)
        Tasks::AuthenticateIdentity.expects(:call)
        PartnersAPI.query(@context, 'query')
      end

      def test_query_fails_gracefully_without_partners_account
        api_stub = Object.new
        PartnersAPI.expects(:new).with(
          ctx: @context,
          token: 'token123',
          url: "#{PartnersAPI.endpoint}/api/cli/graphql",
        ).returns(api_stub)
        api_stub.expects(:query).raises(API::APIRequestNotFoundError)
        @context.expects(:puts).with(
          "{{error: Your account was not found. Please sign up at https://partners.shopify.com/signup}}",
        )
        PartnersAPI.query(@context, 'query')
      end

      def test_query
        api_stub = Object.new
        PartnersAPI.expects(:new).with(
          ctx: @context,
          token: 'token123',
          url: "#{PartnersAPI.endpoint}/api/cli/graphql",
        ).returns(api_stub)
        api_stub.expects(:query).with('query', variables: {}).returns('response')
        assert_equal 'response', PartnersAPI.query(@context, 'query')
      end
    end
  end
end
