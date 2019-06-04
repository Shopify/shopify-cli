require 'test_helper'

module ShopifyCli
  module Tasks
    class AuthenticateShopifyTest < MiniTest::Test
      include TestHelpers::Context
      include TestHelpers::Constants

      def setup
        super
        @dir = Dir.mktmpdir
        @command = ShopifyCli::Commands::Update.new
      end

      def test_store_token
        ShopifyCli::Project.expects(:current).returns(
          TestHelpers::FakeProject.new(
            directory: @context.root,
            config: {
              'app_type' => 'node',
            }
          )
        ).at_least_once
        ShopifyCli::Helpers::EnvFile.expects(:read).returns(
          ShopifyCli::Helpers::EnvFile.new(
            app_type: 'node',
            api_key: 'apikey',
            secret: 'secret',
            shop: 'myshop',
          )
        ).at_least_once
        @context.expects(:system)
        File.stub(:write, true) do
          AuthenticateShopify.any_instance.expects(:wait_for_redirect).returns('mycode')
          stub_request(:post, "https://myshop/admin/oauth/access_token")
            .with(body: "client_id=apikey&client_secret=secret&code=mycode",
              headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'User-Agent' => 'Ruby' })
            .to_return(status: 200, body: '{ "access_token": "accesstoken123" }', headers: {})
          AuthenticateShopify.call(@context)
          assert_equal('accesstoken123', File.read(File.join(ShopifyCli::ROOT, "test/fixtures/.access_token")))
        end
      end
    end
  end
end
