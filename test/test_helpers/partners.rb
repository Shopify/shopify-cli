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
      stub_request(:post, "#{ShopifyCli::Helpers::PartnersAPI.endpoint}/api/cli/graphql").with(
        body: {
          query: File.read(File.join(ShopifyCli::ROOT, "lib/graphql/#{query}.graphql")).tr("\n", ''),
          variables: variables,
        }.to_json,
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Shopify App CLI beta 1e447bb8498c61a2b160a4b8c22d11f1ef98879b '\
            '| Darwin Kernel Version 19.2.0: Sat Nov  9 03:47:04 PST 2019; root:xnu-6153.61.1~20/RELEASE_X86_64',
          'Authorization' => 'Bearer faketoken',
        }
      ).to_return(status: status, body: resp.to_json)
    end
  end
end
