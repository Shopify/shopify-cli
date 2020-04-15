# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module GetOrganizations
        include TestHelpers::Partners

        def stub_get_organizations
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
  end
end
