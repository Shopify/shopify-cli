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
        ShopifyCli::Tunnel.any_instance.expects(:start).never
        ShopifyCli::Tunnel.any_instance.expects(:stop).never
        ShopifyCli::Tunnel.any_instance.expects(:auth)
        run_cmd("php tunnel auth bf934rb9384598b3495")
      end

      def test_auth_no_token
        ShopifyCli::Tunnel.any_instance.expects(:start).never
        ShopifyCli::Tunnel.any_instance.expects(:stop).never
        ShopifyCli::Tunnel.any_instance.expects(:auth).never
        @context.expects(:message).with("php.tunnel.error.token_argument_missing")
        run_cmd("php tunnel auth")
      end

      def test_start
        ShopifyCli::Tunnel.any_instance.expects(:auth).never
        ShopifyCli::Tunnel.any_instance.expects(:stop).never
        ShopifyCli::Tunnel.any_instance.expects(:start)
        run_cmd("php tunnel start")
      end

      def test_stop
        ShopifyCli::Tunnel.any_instance.expects(:auth).never
        ShopifyCli::Tunnel.any_instance.expects(:start).never
        ShopifyCli::Tunnel.any_instance.expects(:stop)
        run_cmd("php tunnel stop")
      end

      def test_prints_help_with_no_args
        ShopifyCli::Context.expects(:message).with("core.options.help_text")
        ShopifyCli::Context.expects(:message).with("php.tunnel.help", ShopifyCli::TOOL_NAME)
        run_cmd("php tunnel")
      end
    end
  end
end
