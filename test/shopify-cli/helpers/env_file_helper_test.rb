# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Helpers
    class EnvFileHelperTest < MiniTest::Test
      include TestHelpers::Context

      class FakeCommand
        class << self
          def env_file(key, secret, host)
            "#{key}, #{secret}, #{host}"
          end
        end
      end

      def test_write_writes_env_content_to_file
        cmd = FakeCommand.new
        @context.app_metadata = {
          apiKey: 'key',
          sharedSecret: 'secret',
          host: 'host',
        }
        @context.expects(:write).with('.env', 'key, secret, host')
        @context.expects(:print_task).with('writing .env file')
        EnvFileHelper.new(cmd, @context).write('.env')
      end
    end
  end
end
