require 'test_helper'

module ShopifyCli
  module Commands
    class ConnectTest < MiniTest::Test
      include TestHelpers::Partners

      def test_run
        stub_partner_req(
          'all_orgs_with_apps',
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    'id': 421,
                    'businessName': "one",
                    'stores': {
                      'nodes': [
                        { 'shopDomain': 'store.myshopify.com' }
                      ]},
                    'apps': {
                      nodes: [
                        title: 'fake',
                        apiKey: '1234',
                        apiSecretKeys: {
                          secret: 1233
                        }
                    ]
                  },
                  },
                  {
                    'id': 431,
                    'businessName': "two",
                    'stores': { 'nodes': [{ 'shopDomain': 'store.myshopify.com', 'shopName': 'store1' },
                      { 'shopDomain': 'store2.myshopify.com', 'shopName': 'store2' }] },
                    'apps': {
                      nodes: [
                        title: 'fake',
                        apiKey: '1234',
                        apiSecretKeys: {
                          secret: 1233
                        }
                    ]
                  },
                  },
                ],
              },
            },
          },
        )
        CLI::UI::Prompt.expects(:ask).with('Which organization does this app belong to?').returns({
          'id': 421,
          'businessName': "one",
          'stores': {
            odes: [
              { 'shopDomain': 'store.myshopify.com', 'shopName': 'store1' },
              { 'shopDomain': 'store2.myshopify.com', 'shopName': 'store2' },
            ]},
          'apps': {
            nodes: [
              title: 'fake',
              apiKey: '1234',
              apiSecretKeys: {
                secret: 1233
              }
          ]
        },
        },)
        CLI::UI::Prompt.expects(:ask).with('Which app does this project belong to?').returns({title:'fake', apiKey:1234, apiSecretKeys:[{secret:1233}]})
        run_cmd('connect')
      end
    end
  end
end