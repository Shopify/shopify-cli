require 'test_helper'

module ShopifyCli
  module Tasks
    class CreateApiClientTest < MiniTest::Test
      include TestHelpers::Partners

      def test_call_will_query_partners_dashboard
        stub_partner_req(
          'create_app',
          variables: {
            org: 42,
            title: 'Test app',
            app_url: 'http://app.com',
            redir: ["http://app-cli-loopback.shopifyapps.com:3456"],
          },
          resp: {
            'data': {
              'appCreate': {
                'app': {
                  'apiKey': 'newapikey',
                  'apiSecretKeys': [{ 'secret': 'secret' }],
                },
              },
            },
          }
        )

        api_client = Tasks::CreateApiClient.call(
          @context,
          org_id: 42,
          title: 'Test app',
          app_url: 'http://app.com',
        )

        refute_nil(api_client)
        assert_equal(api_client['apiKey'], 'newapikey')
      end

      def test_call_will_return_any_user_errors
        stub_partner_req(
          'create_app',
          variables: {
            org: 42,
            title: 'Test app',
            app_url: 'http://app.com',
            redir: ["http://app-cli-loopback.shopifyapps.com:3456"],
          },
          resp: {
            'data': {
              'appCreate': {
                'userErrors': [
                  { 'field': 'app_url', 'message': 'is not a valid url' },
                ],
              },
            },
          }
        )

        err = assert_raises ShopifyCli::Abort do
          Tasks::CreateApiClient.call(
            @context,
            org_id: 42,
            title: 'Test app',
            app_url: 'http://app.com',
          )
        end
        assert_equal(err.message, "app_url is not a valid url")
      end
    end
  end
end
