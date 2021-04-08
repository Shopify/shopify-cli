# frozen_string_literal: true
require "test_helper"
require "uri"

module ShopifyCli
  module Resources
    class EnvFileTest < MiniTest::Test
      def test_default_settings
        ReadEnvFile.call(File.join(Dir.pwd, ".env")).tap do |result|
          assert_predicate(result, :success?)

          result.value.tap do |variables|
            assert_kind_of(Hash, variables)
            assert_predicate(variables, :any?)

            assert_equal "apikey", variables["SHOPIFY_API_KEY"]
            assert_equal "secret", variables["SHOPIFY_API_SECRET"]
            assert_equal "https://example.com", variables["HOST"]
            assert_equal "my-test-shop.myshopify.com", variables["SHOP"]
            assert_equal "awskey", variables["AWSKEY"]
          end
        end
      end

      def test_transforming_keys
        symbolize = ->(key) { key.downcase.to_sym }
        ReadEnvFile
          .call(File.join(Dir.pwd, ".env"), transform_keys: symbolize)
          .tap do |result|
            assert_predicate(result, :success?)

            result.value.tap do |variables|
              assert_equal "apikey", variables[:shopify_api_key]
              assert_equal "secret", variables[:shopify_api_secret]
              assert_equal "https://example.com", variables[:host]
              assert_equal "my-test-shop.myshopify.com", variables[:shop]
              assert_equal "awskey", variables[:awskey]
            end
          end
      end

      def test_transforming_values
        parse_urls = ->(value) do
          case uri = URI(value)
          when URI::HTTP, URI::HTTPS
            uri
          else
            value
          end
        end

        ReadEnvFile
          .call(File.join(Dir.pwd, ".env"), transform_values: parse_urls)
          .tap do |result|
            assert_predicate(result, :success?)

            result.value.tap do |variables|
              assert_kind_of(URI::HTTP, variables["HOST"])
              assert_kind_of(String, variables["SHOP"])
            end
          end
      end
    end
  end
end
