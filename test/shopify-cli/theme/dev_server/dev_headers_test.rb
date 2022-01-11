# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server/dev_headers"

module ShopifyCLI
  module Theme
    module DevServer
      class DevHeadersTest < Minitest::Test
        def test_call
          initial_status = mock("status")
          initial_body = mock("body")
          initial_headers = {
            "key 1" => "value 1",
            "key 2" => "value 2",
            "key 3" => "value 3",
            "content-security-policy" => "value4",
          }
          expected_headers = {
            "key 1" => "value 1",
            "key 2" => "value 2",
            "key 3" => "value 3",
          }
          env = [initial_status, initial_headers, initial_body]

          status, headers, body = DevHeaders.new(fake_app).call(env)

          refute_same(initial_headers, headers)
          assert_same(initial_status, status)
          assert_same(initial_body, body)
          assert_equal(expected_headers, headers)
        end

        private

        def fake_app
          FakeApp.new
        end

        class FakeApp
          def call(env)
            env
          end
        end
      end
    end
  end
end
