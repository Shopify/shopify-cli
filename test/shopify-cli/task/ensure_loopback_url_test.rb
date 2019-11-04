require 'test_helper'

module ShopifyCli
  module Tasks
    class EnsureLoopbackURLTest < MiniTest::Test
      include TestHelpers::Partners

      def test_url_is_not_added_if_it_exists
        Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '123', secret: 'foo'))
        api_key = '123'
        stub_partner_req(
          'get_app_urls',
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                redirectUrlWhitelist: [
                  'https://123abc.ngrok.io',
                  'http://app-cli-loopback.shopifyapps.com:3456',
                ],
              },
            },
          },
        )
        ShopifyCli::Tasks::EnsureLoopbackURL.call(@context)
      end

      def test_url_is_added_if_it_is_not_there
        Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '123', secret: 'foo'))
        api_key = '123'
        stub_partner_req(
          'get_app_urls',
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                redirectUrlWhitelist: [
                  'https://123abc.ngrok.io',
                ],
              },
            },
          },
        )

        stub_partner_req(
          'update_whitelisturls',
          variables: {
            input: {
              redirectUrlWhitelist: [
                'https://123abc.ngrok.io',
                'http://app-cli-loopback.shopifyapps.com:3456',
              ],
              apiKey: api_key,
            },
          },
        )
        ShopifyCli::Tasks::EnsureLoopbackURL.call(@context)
      end
    end
  end
end
