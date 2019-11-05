require 'test_helper'

module ShopifyCli
  module Tasks
    class UpdateWhitelistURLTest < MiniTest::Test
      include TestHelpers::Partners

      def test_url_is_not_transformed_if_same
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
                  'https://123abc.ngrok.io/callback/fake',
                ],
              },
            },
          },
        )
        ShopifyCli::Tasks::UpdateWhitelistURL.call(@context, url: 'https://123abc.ngrok.io')
      end

      def test_url_is_transformed_if_different_and_callback_is_appended
        Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '1234', secret: 'foo'))
        api_key = '1234'
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
                  'https://newone123.ngrok.io/callback/fake',
                ],
              },
            },
          },
        )

        stub_partner_req(
          'update_whitelisturls',
          variables: {
            input: {
              applicationUrl: 'https://newone123.ngrok.io',
              redirectUrlWhitelist: ['https://newone123.ngrok.io', 'https://newone123.ngrok.io/callback/fake'],
              apiKey: api_key,
            },
          },
        )
        ShopifyCli::Tasks::UpdateWhitelistURL.call(@context, url: 'https://newone123.ngrok.io')
      end

      def test_only_ngrok_urls_are_updated
        Project.current.stubs(:env).returns(Helpers::EnvFile.new(api_key: '1234', secret: 'foo'))
        api_key = '1234'
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
                  'https://fake.fakeurl.com',
                  'https://fake.fakeurl.com/callback/fake',
                ],
              },
            },
          }
        )

        stub_partner_req(
          'update_whitelisturls',
          variables: {
            input: {
              applicationUrl: 'https://newone123.ngrok.io',
              redirectUrlWhitelist: [
                'https://newone123.ngrok.io',
                'https://fake.fakeurl.com',
                'https://fake.fakeurl.com/callback/fake',
              ],
              apiKey: api_key,
            },
          }
        )
        ShopifyCli::Tasks::UpdateWhitelistURL.call(@context, url: 'https://newone123.ngrok.io')
      end
    end
  end
end
