# typed: ignore
# frozen_string_literal: true
require "test_helper"

module ShopifyCLI
  class PartnersAPI
    class OrganizationsTest < MiniTest::Test
      include TestHelpers::Partners

      def test_fetch_all_queries_partners
        stub_partner_req(
          "all_organizations",
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 42,
                    stores: {
                      nodes: [
                        {
                          shopDomain: "shopdomain.myshopify.com",
                        },
                      ],
                    },
                  },
                ],
              },
            },
          }
        )

        orgs = PartnersAPI::Organizations.fetch_all(@context)
        assert_equal(1, orgs.count)
        assert_equal(42, orgs.first["id"])
        assert_equal(1, orgs.first["stores"].count)
        assert_equal("shopdomain.myshopify.com", orgs.first["stores"].first["shopDomain"])
      end

      def test_fetch_all_handles_no_shops
        stub_partner_req(
          "all_organizations",
          resp: {
            data: { organizations: { nodes: [{ id: 42, stores: { nodes: [] } }] } },
          }
        )

        orgs = PartnersAPI::Organizations.fetch_all(@context)
        assert_equal(1, orgs.count)
        assert_equal(42, orgs.first["id"])
        assert_equal(0, orgs.first["stores"].count)
      end

      def test_fetch_all_handles_no_orgs
        stub_partner_req(
          "all_organizations",
          resp: { data: { organizations: { nodes: [] } } }
        )

        orgs = PartnersAPI::Organizations.fetch_all(@context)
        assert_equal(0, orgs.count)
      end

      def test_fetch_queries_partners
        stub_partner_req(
          "find_organization",
          variables: { id: 42 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 42,
                    stores: {
                      nodes: [
                        {
                          shopDomain: "shopdomain.myshopify.com",
                        },
                      ],
                    },
                  },
                ],
              },
            },
          }
        )

        org = PartnersAPI::Organizations.fetch(@context, id: 42)
        assert_equal(42, org["id"])
        assert_equal(1, org["stores"].count)
        assert_equal("shopdomain.myshopify.com", org["stores"].first["shopDomain"])
      end

      def test_fetch_returns_nil_when_not_found
        stub_partner_req(
          "find_organization",
          variables: { id: 42 },
          resp: {
            data: {
              organizations: {
                nodes: [],
              },
            },
          }
        )

        org = PartnersAPI::Organizations.fetch(@context, id: 42)
        assert_nil(org)
      end

      def test_fetch_handles_no_shops
        stub_partner_req(
          "find_organization",
          variables: { id: 42 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 42,
                    stores: { nodes: [] },
                  },
                ],
              },
            },
          }
        )

        org = PartnersAPI::Organizations.fetch(@context, id: 42)
        assert_equal(42, org["id"])
        assert_equal(0, org["stores"].count)
      end

      def test_fetch_org_with_app_info
        stub_partner_req(
          "all_orgs_with_apps",
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    'id': 421,
                    'businessName': "one",
                    'stores': {
                      'nodes': [
                        { 'shopDomain': "store.myshopify.com" },
                      ],
                    },
                    'apps': {
                      nodes: [{
                        title: "app",
                        apiKey: 1234,
                        apiSecretKeys: [{
                          secret: 1233,
                        }],
                      }],
                    },
                  },
                  {
                    'id': 431,
                    'businessName': "two",
                    'stores': { 'nodes': [
                      { 'shopDomain': "store.myshopify.com", 'shopName': "store1" },
                      { 'shopDomain': "store2.myshopify.com", 'shopName': "store2" },
                    ] },
                    'apps': {
                      nodes: [{
                        id: 123,
                        title: "fake",
                        apiKey: "1234",
                        apiSecretKeys: [{
                          secret: "1233",
                        }],
                      }],
                    },
                  },
                ],
              },
            },
          },
        )
        orgs = PartnersAPI::Organizations.fetch_with_app(@context)
        assert_equal(2, orgs.count)
        assert_equal(421, orgs.first["id"])
        assert_equal("store.myshopify.com", orgs.first["stores"].first["shopDomain"])
      end

      def test_fetch_org_with_empty_app_info
        stub_partner_req(
          "all_orgs_with_apps",
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    'id': 421,
                    'businessName': "one",
                    'stores': { 'nodes': [] },
                    'apps': { nodes: [] },
                  },
                ],
              },
            },
          },
        )
        orgs = PartnersAPI::Organizations.fetch_with_app(@context)
        assert_equal(1, orgs.count)
        assert_equal(421, orgs.first["id"])
        assert_equal(0, orgs.first["stores"].count)
        assert_equal(0, orgs.first["apps"].count)
      end

      def test_fetch_all_with_nil_resp
        stub_partner_req_not_found("all_organizations")
        orgs = PartnersAPI::Organizations.fetch_all(@context)
        assert_equal([], orgs)
      end

      def test_fetch_with_extensions
        type = "THEME_APP_EXTENSION"
        stub_all_orgs_with_apps
        stub_get_extension_registrations(type)

        orgs = PartnersAPI::Organizations.fetch_with_extensions(@context, type)

        assert_equal(1, orgs.size)
        org = orgs.first

        assert_equal(1, org["apps"].size)
        app = orgs.first["apps"].first

        assert_equal(1, app["extensionRegistrations"].size)
        registration = app["extensionRegistrations"].first

        assert_equal(1, org["id"])
        assert_equal(4, app["id"])
        assert_equal(2, app["apiKey"])
        assert_equal(6, registration["id"])
        assert_equal(7, registration["draftVersion"]["registrationId"])
      end

      def test_fetch_with_extensions_with_nil_resp
        stub_partner_req_not_found("all_orgs_with_apps")
        type = "THEME_APP_EXTENSION"
        orgs = PartnersAPI::Organizations.fetch_with_extensions(@context, type)
        assert_equal([], orgs)
      end

      private

      def stub_all_orgs_with_apps
        stub_partner_req(
          "all_orgs_with_apps",
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 1,
                    businessName: "partner org",
                    stores: {
                      nodes: [{ shopDomain: "partner-store.myshopify.com" }],
                    },
                    apps: {
                      nodes: [{
                        title: "ext1",
                        apiKey: 2,
                        apiSecretKeys: [{ secret: 3 }],
                      }],
                    },
                  },
                ],
              },
            },
          },
        )
      end

      def stub_get_extension_registrations(type)
        stub_partner_req(
          "get_extension_registrations",
          variables: {
            api_key: 2,
            type: type,
          },
          resp: {
            data: {
              app: {
                id: 4,
                title: "ext1",
                apiKey: 2,
                apiSecretKeys: [{ secret: 3 }],
                appType: "custom",
                extensionRegistrations: [{
                  id: 6,
                  type: type,
                  uuid: "AAAA-1111-2222-3333",
                  title: "app1",
                  draftVersion: {
                    registrationId: 7,
                    lastUserInteractionAt: "2000-01-01T12:30:00-00:00",
                    location: "https://partners.shopify.com/1/apps/4/extensions/theme_app_extension/6",
                    validationErrors: [],
                    id: 8,
                    uuid: "BBBB-1111-2222-3333",
                    versionTag: "0.0.0",
                  },
                }],
              },
            },
          },
        )
      end
    end
  end
end
