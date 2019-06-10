# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Helpers
    class EnvFileHelperTest < MiniTest::Test
      include TestHelpers::AppType

      def test_read_reads_env_content_from_file
        env_file = EnvFile.read(TestHelpers::AppType::FakeAppType, fixture)
        assert_equal(env_file.api_key, 'foo')
        assert_equal(env_file.secret, 'bar')
        assert_equal(env_file.host, 'baz')
      end

      def test_write_writes_env_content_to_file
        env_file = EnvFile.new(
          app_type: TestHelpers::AppType::FakeAppType.new(ctx: @context, name: 'fake'),
          api_key: 'foo',
          secret: 'bar',
          host: 'baz'
        )
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
