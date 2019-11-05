# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Helpers
    class EnvFileTest < MiniTest::Test
      def test_read_reads_env_content_from_file
        env_file = EnvFile.read
        assert_equal(env_file.api_key, 'apikey')
        assert_equal(env_file.secret, 'secret')
        assert_equal(env_file.host, 'https://example.com')
        assert_equal(env_file.shop, 'my-test-shop.myshopify.com')
      end

      def test_write_writes_env_content_to_file
        env_file = EnvFile.new(
          api_key: 'foo',
          secret: 'bar',
          host: 'baz'
        )
        content = <<~CONTENT
          API_KEY=foo
          SECRET=bar
          HOST=baz
        CONTENT
        @context.expects(:write).with('.env', content)
        @context.expects(:print_task).with('writing .env file')
        env_file.write(@context)
      end
    end
  end
end
