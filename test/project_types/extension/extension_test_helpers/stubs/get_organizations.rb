# typed: ignore
# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module GetOrganizations
        include TestHelpers::Partners

        def organization(name:, apps:)
          {
            name: name,
            apps: apps,
          }
        end

        def stub_get_organizations(organizations)
          stub_partner_req(
            "all_orgs_with_apps",
            resp: {
              data: {
                organizations: {
                  nodes: create_organizations_json(organizations),
                },
              },
            },
          )
        end

        def create_organizations_json(organizations)
          organizations.map do |organization|
            create_organization_json(name: organization[:name], apps: organization[:apps])
          end
        end

        def create_organization_json(name:, apps:)
          {
            'id': rand(9999),
            'businessName': name,
            'stores': {
              'nodes': [
                { 'shopDomain': "store.myshopify.com" },
              ],
            },
            'apps': {
              nodes: create_apps_json(apps),
            },
          }
        end

        def create_apps_json(apps)
          apps.map do |app|
            {
              id: rand(9999),
              title: app.title,
              'apiKey': app.api_key,
              'apiSecretKeys': [{ 'secret': app.secret }],
            }
          end
        end
      end
    end
  end
end
