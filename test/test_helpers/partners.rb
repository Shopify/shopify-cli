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
        headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'Bearer faketoken',
          'Content-Type'=>'application/json',
          'User-Agent'=>"Shopify App CLI #{ShopifyCli::VERSION} abcde | Mac"},
      }.to_json).to_return(status: status, body: resp.to_json)
    end
  end
end
