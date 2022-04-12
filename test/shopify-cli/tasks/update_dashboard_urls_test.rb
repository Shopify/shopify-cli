require "test_helper"

module ShopifyCLI
  module Tasks
    class UpdateDashboardURLSTest < MiniTest::Test
      include TestHelpers::Partners

      def test_url_is_not_transformed_if_same
        Project.current.stubs(:env).returns(Resources::EnvFile.new(api_key: "123", secret: "foo"))
        api_key = "123"
        get_request = stub_partner_req(
          "get_app_urls",
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                applicationUrl: "https://123abc.ngrok.io/",
                redirectUrlWhitelist: [
                  "https://123abc.ngrok.io",
                  "https://123abc.ngrok.io/callback/fake",
                ],
              },
            },
          },
        )
        ShopifyCLI::Tasks::UpdateDashboardURLS.call(
          @context,
          url: "https://123abc.ngrok.io",
          callback_urls: ["/callback/fake"],
        )
        assert_requested(get_request)
      end

      def test_url_is_transformed_if_different_and_callback_is_appended
        Project.current.stubs(:env).returns(Resources::EnvFile.new(api_key: "1234", secret: "foo"))
        api_key = "1234"
        get_request = stub_partner_req(
          "get_app_urls",
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                applicationUrl: "https://oldone123.ngrok.io",
                redirectUrlWhitelist: [
                  "https://123abc.ngrok.io",
                  "https://newone123.ngrok.io/callback/fake",
                ],
              },
            },
          },
        )

        update_request = stub_partner_req(
          "update_dashboard_urls",
          variables: {
            input: {
              applicationUrl: "https://newone123.ngrok.io",
              redirectUrlWhitelist: ["https://newone123.ngrok.io", "https://newone123.ngrok.io/callback/fake"],
              apiKey: api_key,
            },
          },
        )
        ShopifyCLI::Tasks::UpdateDashboardURLS.call(
          @context,
          url: "https://newone123.ngrok.io",
          callback_urls: ["/callback/fake"],
        )
        assert_requested(get_request)
        assert_requested(update_request)
      end

      def test_only_ngrok_urls_are_updated
        Project.current.stubs(:env).returns(Resources::EnvFile.new(api_key: "1234", secret: "foo"))
        api_key = "1234"
        get_request = stub_partner_req(
          "get_app_urls",
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                applicationUrl: "https://oldone123.ngrok.io",
                redirectUrlWhitelist: [
                  "https://123abc.ngrok.io",
                  "https://fake.fakeurl.com",
                  "https://fake.fakeurl.com/callback/fake",
                ],
              },
            },
          }
        )

        update_request = stub_partner_req(
          "update_dashboard_urls",
          variables: {
            input: {
              applicationUrl: "https://newone123.ngrok.io",
              redirectUrlWhitelist: [
                "https://newone123.ngrok.io",
                "https://fake.fakeurl.com",
                "https://fake.fakeurl.com/callback/fake",
                "https://newone123.ngrok.io/callback/fake",
              ],
              apiKey: api_key,
            },
          }
        )
        ShopifyCLI::Tasks::UpdateDashboardURLS.call(
          @context,
          url: "https://newone123.ngrok.io",
          callback_urls: ["/callback/fake"],
        )
        assert_requested(get_request)
        assert_requested(update_request)
      end

      def test_whitelist_urls_are_updated_even_if_app_url_is_set
        Project.current.stubs(:env).returns(Resources::EnvFile.new(api_key: "123", secret: "foo"))
        api_key = "123"
        get_request = stub_partner_req(
          "get_app_urls",
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                applicationUrl: "https://oldone123.ngrok.io",
                redirectUrlWhitelist: [],
              },
            },
          }
        )

        update_request = stub_partner_req(
          "update_dashboard_urls",
          variables: {
            input: {
              applicationUrl: "https://newone123.ngrok.io",
              redirectUrlWhitelist: [
                "https://newone123.ngrok.io/callback/fake",
              ],
              apiKey: api_key,
            },
          }
        )
        ShopifyCLI::Tasks::UpdateDashboardURLS.call(
          @context,
          url: "https://newone123.ngrok.io",
          callback_urls: ["/callback/fake"],
        )
        assert_requested(get_request)
        assert_requested(update_request)
      end

      def test_multiple_callbacks
        Project.current.stubs(:env).returns(Resources::EnvFile.new(api_key: "1234", secret: "foo"))
        api_key = "1234"
        get_request = stub_partner_req(
          "get_app_urls",
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                applicationUrl: "https://oldone123.ngrok.io",
                redirectUrlWhitelist: [
                  "https://123abc.ngrok.io",
                  "https://newone123.ngrok.io/callback/fake",
                ],
              },
            },
          },
        )

        update_request = stub_partner_req(
          "update_dashboard_urls",
          variables: {
            input: {
              applicationUrl: "https://newone123.ngrok.io",
              redirectUrlWhitelist: [
                "https://newone123.ngrok.io",
                "https://newone123.ngrok.io/callback/fake",
                "https://newone123.ngrok.io/callback/shopify/fake",
              ],
              apiKey: api_key,
            },
          },
        )
        ShopifyCLI::Tasks::UpdateDashboardURLS.call(
          @context,
          url: "https://newone123.ngrok.io",
          callback_urls: ["/callback/fake", "/callback/shopify/fake"],
        )
        assert_requested(get_request)
        assert_requested(update_request)
      end
    end
  end
end
