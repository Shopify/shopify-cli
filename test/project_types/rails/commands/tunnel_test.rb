# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class TunnelTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::Tasks::EnsureProjectType.expects(:call).with(@context, :rails)
      end

      def test_auth
        ShopifyCLI::Tunnel.any_instance.expects(:auth)
        run_cmd("app rails tunnel auth adfhauf98q7rtqhfkajf")
      end

      def test_auth_no_token
        ShopifyCLI::Tunnel.any_instance.expects(:auth).never
        run_cmd("app rails tunnel auth")
      end

      def test_start
        ShopifyCLI::Tunnel.any_instance.expects(:start)
        run_cmd("app rails tunnel start")
      end

      def test_stop
        ShopifyCLI::Tunnel.any_instance.expects(:stop)
        run_cmd("app rails tunnel stop")
      end
    end
  end
end
