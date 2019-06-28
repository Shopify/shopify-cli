require 'test_helper'

module ShopifyCli
  module Tasks
    class AuthenticateShopifyTest < MiniTest::Test
      include TestHelpers::Project
      include TestHelpers::Constants

      def setup
        super
        @command = ShopifyCli::Commands::Update.new
        TCPServer.stubs(:new)
      end

      def test_store_token
        ShopifyCli::Helpers::AccessToken.expects(:read).returns(
          File.read(File.join(ShopifyCli::ROOT, "test/fixtures/.apikey"))
        )
        @context.expects(:system)
        File.stub(:write, true) do
          AuthenticateShopify.any_instance.expects(:wait_for_redirect).returns('mycode')
          stub_request(:post, "https://my-test-shop.myshopify.com/admin/oauth/access_token")
            .with(body: "client_id=apikey&client_secret=secret&code=mycode",
              headers: {
                'Accept' => '*/*',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'User-Agent' => 'Ruby',
              })
            .to_return(status: 200, body: '{ "access_token": "accesstoken123" }', headers: {})
          AuthenticateShopify.call(@context)
          assert_equal('accesstoken123', ShopifyCli::Helpers::AccessToken.read(@context))
        end
      end
    end
  end
end
