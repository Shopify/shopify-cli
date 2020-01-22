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

    def stub_load_query(name, body)
      ShopifyCli::API.any_instance.stubs(:load_query).with(name).returns(body)
    end

    def stub_partner_req(query, variables: {}, status: 200, resp: {})
      current_sha = ShopifyCli::Helpers::Git.sha(dir: ShopifyCli::ROOT)
      os_uname = CLI::Kit::System.capture2("uname -v")[0].strip
      stub_request(:post, "#{ShopifyCli::Helpers::PartnersAPI.endpoint}/api/cli/graphql").with(
        body: {
          query: File.read(File.join(ShopifyCli::ROOT, "lib/graphql/#{query}.graphql")).tr("\n", ''),
          variables: variables,
        }.to_json,
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json',
          'User-Agent' => "Shopify App CLI #{ShopifyCli::VERSION} #{current_sha} | #{os_uname}",
          'Authorization' => 'Bearer faketoken',
        }
      ).to_return(status: status, body: resp.to_json)
    end
  end
end
