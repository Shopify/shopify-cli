# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme_admin_api_throttler/put_request"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class PutRequestTest < Minitest::Test
        def setup
          super
        end

        def test_to_h
          op = generate_operation("file1.json")
          put_request = PutRequest.new(op[:path], op[:body])
          expected_output = {
            method: "PUT",
            path: op[:path],
            body: op[:body],
          }
          assert_equal(put_request.to_h, expected_output)
        end

        def test_to_s
          op = generate_operation("file1.json")
          put_request = PutRequest.new(op[:path], op[:body])
          put_request.retries += 10

          expected_output = "file1.json, retries: 10"
          assert_equal(put_request.to_s, expected_output)
        end

        def test_liquid?
          op1 = generate_operation("file1.json")
          put_request_1 = PutRequest.new(op1[:path], op1[:body])

          op2 = generate_operation("file1.liquid")
          put_request_2 = PutRequest.new(op2[:path], op2[:body])

          refute(put_request_1.liquid?)
          assert(put_request_2.liquid?)
        end

        def test_key
          op1 = generate_operation("file1.json")
          put_request = PutRequest.new(op1[:path], op1[:body])
          assert_equal("file1.json", put_request.key)
        end

        def test_bulk_path
          op1 = generate_operation("file1.json")
          put_request = PutRequest.new(op1[:path], op1[:body])

          assert_equal("themes/1/assets/bulk.json", put_request.bulk_path)
        end

        def test_size
          op1 = generate_operation("file1.json")
          put_request = PutRequest.new(op1[:path], op1[:body])

          assert_equal(put_request.size, op1[:body].bytesize)
        end

        private

        def generate_operation(name)
          {
            path: "themes/1/assets.json",
            body: JSON.generate({
              asset: {
                key: name,
                value: name,
              },
            }),
          }
        end
      end
    end
  end
end
