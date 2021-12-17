# frozen_string_literal: true

require "test_helper"

module ShopifyCLI
  class PartnersAPI
    class AppExtensions
      class JobTest < MiniTest::Test
        include TestHelpers::Partners

        def setup
          super
          @app = { "apiKey" => 1 }
          @type = "THEME_APP_EXTENSION"
          @job = PartnersAPI::AppExtensions::Job.new(@context, @app, @type)
        end

        def test_perform
          stub_get_extension_registrations

          expected_result = {
            "apiKey" => 1,
            "id" => 2,
            "extensionRegistrations" => [{ "id" => 3 }],
          }

          assert_nil(@job.result)
          @job.perform!
          assert_equal(expected_result, @job.result)
        end

        def test_patch_app_with_extensions
          expected_app = {
            "apiKey" => 1,
            "id" => 2,
            "extensionRegistrations" => [{ "id" => 3 }],
          }

          @job.stubs(:result).returns(expected_app)
          assert_equal({ "apiKey" => 1 }, @app)

          @job.patch_app_with_extensions!
          assert_equal(expected_app, @app)
        end

        private

        def stub_get_extension_registrations
          stub_partner_req(
            "get_extension_registrations",
            variables: {
              api_key: 1,
              type: @type,
            },
            resp: {
              data: {
                app: {
                  id: 2,
                  apiKey: 1,
                  extensionRegistrations: [{ id: 3 }],
                },
              },
            },
          )
        end
      end
    end
  end
end
