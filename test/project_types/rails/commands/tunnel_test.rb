# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class TunnelTest < MiniTest::Test
      def test_auth
        ShopifyCli::Tunnel.any_instance.expects(:auth)
        run_cmd("tunnel auth adfhauf98q7rtqhfkajf")
      end

      def test_auth_no_token
        ShopifyCli::Tunnel.any_instance.expects(:auth).never
        run_cmd("tunnel auth")
      end

      def test_start
        ShopifyCli::Tunnel.any_instance.expects(:start)
        run_cmd("tunnel start")
      end

      def test_stop
        ShopifyCli::Tunnel.any_instance.expects(:stop)
        run_cmd("tunnel stop")
      end
    end
  end
end
