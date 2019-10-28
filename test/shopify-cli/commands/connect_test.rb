require 'test_helper'

module ShopifyCli
  module Commands
    class ConnectTest < MiniTest::Test
      include TestHelpers::Partners

      def test_run
        stub_partner_req(
          'all_organizations',
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    'id': 421,
                    'businessName': "one",
                    'stores': { 'nodes': [{ 'shopDomain': 'store.myshopify.com' }] },
                  },
                  {
                    'id': 431,
                    'businessName': "two",
                    'stores': { 'nodes': [{ 'shopDomain': 'other.myshopify.com' }] },
                  },
                ],
              },
            },
          },
        )
        CLI::UI::Prompt.expects(:ask).returns(431)
        stub_partner_req(
          'find_organization',
          variables: { id: 431 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 42,
                    businessName: 'hi',
                    website: 'www.fake.com',
                    stores: {
                      nodes: [
                        {
                          shopName: 'fake',
                          shopDomain: 'shopdomain.myshopify.com',
                        },
                      ],
                    },
                    apps: {
                      nodes: [
                        id: 123,
                        title: 'fake',
                        apiKey: '1234',
                      ]
                    }
                  },
                ],
              },
            },
          }
        )
        CLI::UI::Prompt.expects(:ask).returns(123)
        stub_partner_req(
          'get_app',
          variables: { apiKey: 123 },
          resp: {
            data: {
              apiKey: 123,
              apiSecretKeys: {
                secret: 1233
              }
            },
          }
        )
        run_cmd('connect')
      end
    end
  end
end
