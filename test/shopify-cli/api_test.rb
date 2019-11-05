require 'test_helper'

module ShopifyCli
  class APITest < MiniTest::Test
    def setup
      super
      @api = API.new(
        ctx: @context,
        auth_header: 'Auth',
        token: 'faketoken',
        url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      )
      Helpers::Git.stubs(:sha).returns('abcde')
      @api.stubs(:uname).with(flag: 'v').returns('Mac')
    end

    def test_mutation_makes_request_to_shopify
      mutation = <<~MUTATION
        mutation {
          fakeMutation(input: {
            title: "fake title"
          }) {
            id
          }
        }
      MUTATION
      stub_request(:post, 'https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json')
        .with(body: File.read(File.join(FIXTURE_DIR, 'api/mutation.json')).tr("\n", ''),
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => "Shopify App CLI #{ShopifyCli::VERSION} abcde | Mac",
            'Auth' => 'faketoken',
          })
        .to_return(status: 200, body: '{}')

      File.stubs(:read)
        .with(File.join(ShopifyCli::ROOT, "lib/graphql/api/mutation.graphql"))
        .returns(mutation)
      @api.query('api/mutation')
    end
  end
end
