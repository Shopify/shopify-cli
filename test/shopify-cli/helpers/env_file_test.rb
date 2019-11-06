# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Helpers
    class EnvFileTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_read_reads_env_content_from_file
        env_file = EnvFile.read
        assert_equal(env_file.api_key, 'apikey')
        assert_equal(env_file.secret, 'secret')
        assert_equal(env_file.host, 'https://example.com')
        assert_equal(env_file.shop, 'my-test-shop.myshopify.com')
        assert_equal(env_file.extra['AWSKEY'], 'awskey')
      end

      def test_write_writes_env_content_to_file
        env_file = EnvFile.new(
          api_key: 'foo',
          secret: 'bar',
          host: 'baz',
          extra: { 'AWSKEY' => 'awskey' },
        )
        content = <<~CONTENT
          SHOPIFY_API_KEY=foo
          SHOPIFY_API_SECRET=bar
          HOST=baz
          AWSKEY=awskey
        CONTENT
        @context.expects(:write).with('.env', content)
        @context.expects(:print_task).with('writing .env file')
        env_file.write(@context)
      end

      def test_update_writes_new_value_to_file
        env_file = EnvFile.new(
          api_key: 'foo',
          secret: 'bar',
          host: 'baz'
        )
        content = <<~CONTENT
          SHOPIFY_API_KEY=foo
          SHOPIFY_API_SECRET=bar
          HOST=boo
        CONTENT
        @context.expects(:write).with('.env', content)
        @context.expects(:print_task).with('writing .env file')
        env_file.update(@context, :host, 'boo')
      end
    end
  end
end
