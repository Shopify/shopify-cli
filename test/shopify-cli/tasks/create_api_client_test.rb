require "test_helper"

module ShopifyCLI
  module Tasks
    class CreateApiClientTest < MiniTest::Test
      include TestHelpers::Partners

      def teardown
        ShopifyCLI::Core::Monorail.metadata = {}
        super
      end

      def test_call_will_query_partners_dashboard
        stub_partner_req(
          "create_app",
          variables: {
            org: 42,
            title: "Test app",
            type: "public",
            app_url: ShopifyCLI::Tasks::CreateApiClient::DEFAULT_APP_URL,
            redir: ["http://127.0.0.1:3456"],
          },
          resp: {
            'data': {
              'appCreate': {
                'app': {
                  'apiKey': "newapikey",
                  'apiSecretKeys': [{ 'secret': "secret" }],
                },
              },
            },
          }
        )

        api_client = Tasks::CreateApiClient.call(
          @context,
          org_id: 42,
          title: "Test app",
          type: "public",
        )

        refute_nil(api_client)
        assert_equal("newapikey", api_client["apiKey"])
        assert_equal("newapikey", ShopifyCLI::Core::Monorail.metadata[:api_key])
      end

      def test_call_will_return_any_general_errors
        stub_partner_req(
          "create_app",
          variables: {
            org: 42,
            title: "Test app",
            type: "public",
            app_url: ShopifyCLI::Tasks::CreateApiClient::DEFAULT_APP_URL,
            redir: ["http://127.0.0.1:3456"],
          },
          resp: {
            'errors': [
              { 'field': "title", 'message': "is not a valid title" },
            ],
          }
        )

        err = assert_raises ShopifyCLI::Abort do
          Tasks::CreateApiClient.call(
            @context,
            org_id: 42,
            title: "Test app",
            type: "public",
          )
        end
        assert_equal("{{x}} title is not a valid title", err.message)
      end

      def test_call_will_return_any_user_errors
        stub_partner_req(
          "create_app",
          variables: {
            org: 42,
            title: "Test app",
            type: "public",
            app_url: ShopifyCLI::Tasks::CreateApiClient::DEFAULT_APP_URL,
            redir: ["http://127.0.0.1:3456"],
          },
          resp: {
            'data': {
              'appCreate': {
                'userErrors': [
                  { 'field': "title", 'message': "is not a valid title" },
                ],
              },
            },
          }
        )

        err = assert_raises ShopifyCLI::Abort do
          Tasks::CreateApiClient.call(
            @context,
            org_id: 42,
            title: "Test app",
            type: "public",
          )
        end
        assert_equal("{{x}} title is not a valid title", err.message)
      end
    end
  end
end
