# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Helpers
    class OrganizationsTest < MiniTest::Test
      include TestHelpers::Partners

      def test_fetch_all_queries_partners
        stub_partner_req(
          'all_organizations',
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 42,
                    stores: {
                      nodes: [
                        {
                          shopDomain: 'shopdomain.myshopify.com',
                        },
                      ],
                    },
                  },
                ],
              },
            },
          }
        )

        orgs = Helpers::Organizations.fetch_all(@context)
        assert_equal(orgs.count, 1)
        assert_equal(orgs.first['id'], 42)
        assert_equal(orgs.first['stores'].count, 1)
        assert_equal(orgs.first['stores'].first['shopDomain'], 'shopdomain.myshopify.com')
      end

      def test_fetch_queries_partners
        stub_partner_req(
          'find_organization',
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
                          shopDomain: 'shopdomain.myshopify.com',
                        },
                      ],
                    },
                  },
                ],
              },
            },
          }
        )

        org = Helpers::Organizations.fetch(@context, id: 42)
        assert_equal(org['id'], 42)
        assert_equal(org['stores'].count, 1)
        assert_equal(org['stores'].first['shopDomain'], 'shopdomain.myshopify.com')
      end

      def test_fetch_returns_nil_when_not_found
        stub_partner_req(
          'find_organization',
          variables: { id: 42 },
          resp: {
            data: {
              organizations: {
                nodes: [],
              },
            },
          }
        )

        org = Helpers::Organizations.fetch(@context, id: 42)
        assert_nil(org)
      end
    end
  end
end
