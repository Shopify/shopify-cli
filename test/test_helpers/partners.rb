# frozen_string_literal: true
module TestHelpers
  module Partners
    def setup
      ShopifyCli::Helpers::Store.set(identity_exchange_token: 'faketoken')
      super
    end

    def teardown
      ShopifyCli::Helpers::Store.del(:identity_exchange_token)
      super
    end

    def stub_partner_req(query, variables: {}, status: 200, resp: {})
      stub_request(:post, "https://partners.shopify.com/api/cli/graphql").with(body: {
        query: File.read(File.join(ShopifyCli::ROOT, "lib/graphql/#{query}.graphql")).tr("\n", ''),
        variables: variables,
      }.to_json).to_return(status: status, body: resp.to_json)
    end
  end
end
