# frozen_string_literal: true

module Extension
  module Stubs
    include TestHelpers

    def stub_query_for_fetch_organizations_with_apps
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
                      { 'shopDomain': 'store.myshopify.com' },
                    ],
                  },
                  'apps': {
                    nodes: [{
                              id: 123,
                              title: 'app',
                              'apiKey': '1234',
                              'apiSecretKeys': [{
                                                  'secret': "1233",
                                                }],
                            }],
                  },
                },
              ],
            },
          },
        },
        )
    end
  end
end
