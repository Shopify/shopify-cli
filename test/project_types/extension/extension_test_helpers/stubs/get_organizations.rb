# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module Stubs
      module GetOrganizations
        include TestHelpers::Partners

        def organization(id: rand(9999), name:, apps:)
          {
            id: id,
            name: name,
            apps: apps,
          }
        end

        def stub_db_setup(organization_id:)
          ShopifyCLI::DB.stubs(:get).with(:organization_id).returns(organization_id)
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

        def stub_fetch_org_with_apps(organization)
          stub_partner_req(
            "find_organization_with_apps",
            variables: { id: organization[:id] },
            resp: {
              data: {
                organizations: {
                  nodes: [create_organization_json(organization: organization)],
                },
              },
            },
          )
        end

        def create_organizations_json(organizations)
          organizations.map do |organization|
            create_organization_json(organization: organization)
          end
        end

        def create_organization_json(organization:)
          {
            'id': organization[:id],
            'businessName': organization[:name],
            'stores': {
              'nodes': [
                { 'shopDomain': "store.myshopify.com" },
              ],
            },
            'apps': {
              nodes: create_apps_json(organization[:apps]),
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
