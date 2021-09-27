# frozen_string_literal: true
require "project_types/php/test_helper"

module PHP
  module Commands
    class TunnelTest < MiniTest::Test
      def setup
        super
        project_context("app_types", "php")
      end

      def test_auth
        ShopifyCLI::Tunnel.any_instance.expects(:start).never
        ShopifyCLI::Tunnel.any_instance.expects(:stop).never
        ShopifyCLI::Tunnel.any_instance.expects(:auth)
        run_cmd("app php tunnel auth bf934rb9384598b3495")
      end

      def test_auth_no_token
        ShopifyCLI::Tunnel.any_instance.expects(:start).never
        ShopifyCLI::Tunnel.any_instance.expects(:stop).never
        ShopifyCLI::Tunnel.any_instance.expects(:auth).never
        @context.expects(:message).with("php.tunnel.error.token_argument_missing")
        run_cmd("app php tunnel auth")
      end

      def test_start
        ShopifyCLI::Tunnel.any_instance.expects(:auth).never
        ShopifyCLI::Tunnel.any_instance.expects(:stop).never
        ShopifyCLI::Tunnel.any_instance.expects(:start)
        run_cmd("app php tunnel start")
      end

      def test_stop
        ShopifyCLI::Tunnel.any_instance.expects(:auth).never
        ShopifyCLI::Tunnel.any_instance.expects(:start).never
        ShopifyCLI::Tunnel.any_instance.expects(:stop)
        run_cmd("app php tunnel stop")
      end

      def test_prints_help_with_no_args
        ShopifyCLI::Context.expects(:message).with("core.options.help_text")
        ShopifyCLI::Context.expects(:message).with("php.tunnel.help", ShopifyCLI::TOOL_NAME)
        run_cmd("app php tunnel")
      end
    end
  end
end
