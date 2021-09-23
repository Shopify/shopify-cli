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
    end
  end
end
