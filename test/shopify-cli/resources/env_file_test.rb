# typed: ignore
# frozen_string_literal: true
require "test_helper"

module ShopifyCLI
  module Resources
    class EnvFileTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_read_reads_env_content_from_file
        env_file = EnvFile.read
        assert_equal("apikey", env_file.api_key)
        assert_equal("secret", env_file.secret)
        assert_equal("https://example.com", env_file.host)
        assert_equal("my-test-shop.myshopify.com", env_file.shop)
        assert_equal("awskey", env_file.extra["AWSKEY"])
      end

      def test_parse_external_env
        env_file = EnvFile.parse_external_env
        assert_equal("apikey", env_file[:api_key])
        assert_equal("secret", env_file[:secret])
        assert_equal("https://example.com", env_file[:host])
        assert_equal("my-test-shop.myshopify.com", env_file[:shop])
        assert_equal({ "AWSKEY" => "awskey" }, env_file[:extra])
      end

      def test_write_writes_env_content_to_file
        env_file = EnvFile.new(
          api_key: "foo",
          secret: "bar",
          host: "baz",
          extra: { "AWSKEY" => "awskey" },
        )
        content = <<~CONTENT
          SHOPIFY_API_KEY=foo
          SHOPIFY_API_SECRET=bar
          HOST=baz
          AWSKEY=awskey
        CONTENT
        @context.expects(:write).with(".env", content)
        @context.expects(:print_task).with("writing .env file")
        env_file.write(@context)
      end

      def test_update_writes_new_value_to_file
        env_file = EnvFile.new(
          api_key: "foo",
          secret: "bar",
          host: "baz"
        )
        content = <<~CONTENT
          SHOPIFY_API_KEY=foo
          SHOPIFY_API_SECRET=bar
          HOST=boo
        CONTENT
        @context.expects(:write).with(".env", content)
        @context.expects(:print_task).with("writing .env file")
        env_file.update(@context, :host, "boo")
      end
    end
  end
end
