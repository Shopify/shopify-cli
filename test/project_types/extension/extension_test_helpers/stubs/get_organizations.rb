# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module GetOrganizations
        include TestHelpers::Partners

        def stub_get_organizations(organization_name: 'one', app_title: 'App', api_key: '1234', api_secret: '5678')
          stub_partner_req(
            'all_orgs_with_apps',
            resp: {
              data: {
                organizations: {
                  nodes: [
                    {
                      'id': rand(9999),
                      'businessName': organization_name,
                      'stores': {
                        'nodes': [
                          { 'shopDomain': 'store.myshopify.com' },
                        ],
                      },
                      'apps': {
                        nodes: [{
                                  id: rand(9999),
                                  title: app_title,
                                  'apiKey': api_key,
                                  'apiSecretKeys': [{
                                                      'secret': api_secret,
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

        def stub_no_organizations
          stub_partner_req(
            'all_orgs_with_apps',
            resp: {
              data: {
                organizations: {
                  nodes: []
                },
              },
            },
          )
        end

        def stub_no_apps(organization_name)
          stub_partner_req(
            'all_orgs_with_apps',
            resp: {
              data: {
                organizations: {
                  nodes: [
                    {
                      'id': rand(9999),
                      'businessName': organization_name,
                      'stores': {
                        'nodes': [
                          { 'shopDomain': 'store.myshopify.com' },
                        ],
                      },
                      'apps': { nodes: [] },
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
