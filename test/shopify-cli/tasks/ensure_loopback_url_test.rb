require "test_helper"

module ShopifyCLI
  module Tasks
    class EnsureLoopbackURLTest < MiniTest::Test
      include TestHelpers::Partners

      def test_url_is_not_added_if_it_exists
        Project.current.stubs(:env).returns(Resources::EnvFile.new(api_key: "123", secret: "foo"))
        api_key = "123"
        stub_partner_req(
          "get_app_urls",
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                redirectUrlWhitelist: [
                  "https://example.loca.lt",
                  "http://127.0.0.1:3456",
                ],
              },
            },
          },
        )
        ShopifyCLI::Tasks::EnsureLoopbackURL.call(@context)
      end

      def test_url_is_added_if_it_is_not_there
        Project.current.stubs(:env).returns(Resources::EnvFile.new(api_key: "123", secret: "foo"))
        api_key = "123"
        stub_partner_req(
          "get_app_urls",
          variables: {
            apiKey: api_key,
          },
          resp: {
            data: {
              app: {
                redirectUrlWhitelist: [
                  "https://example.loca.lt",
                ],
              },
            },
          },
        )

        stub_partner_req(
          "update_dashboard_urls",
          variables: {
            input: {
              redirectUrlWhitelist: [
                "https://example.loca.lt",
                "http://127.0.0.1:3456",
              ],
              apiKey: api_key,
            },
          },
        )
        ShopifyCLI::Tasks::EnsureLoopbackURL.call(@context)
      end
    end
  end
end
