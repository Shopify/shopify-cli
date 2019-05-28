# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Helpers
    class EnvFileHelperTest < MiniTest::Test
      include TestHelpers::Context

      class FakeCommand
        class << self
          def env_file
            <<~ENV
              SHOPIFY_API_KEY={api_key}
              SHOPIFY_SECRET={secret}
              SHOPIFY_HOST={host}
            ENV
          end
        end
      end

      def test_read_reads_env_content_from_file
        cmd = FakeCommand.new
        env_file = EnvFile.read(cmd, fixture)
        assert_equal(env_file.api_key, 'foo')
        assert_equal(env_file.secret, 'bar')
        assert_equal(env_file.host, 'baz')
      end

      def test_write_writes_env_content_to_file
        cmd = FakeCommand.new
        env_file = EnvFile.new(app_type: cmd, api_key: 'foo', secret: 'bar', host: 'baz')
        @context.expects(:write).with('.env', File.read(fixture))
        @context.expects(:print_task).with('writing .env file')
        env_file.write(@context, '.env')
      end

      def fixture
        File.join(ShopifyCli::ROOT, 'test/fixtures/env_file_read.env')
      end
    end
  end
end
