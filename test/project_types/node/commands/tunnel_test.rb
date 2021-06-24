# frozen_string_literal: true
require "project_types/node/test_helper"

module Node
  module Commands
    class TunnelTest < MiniTest::Test
      def setup
        super
        ShopifyCli::Tasks::EnsureProjectType.expects(:call).with(@context, :node)
      end

      def test_auth
        ShopifyCli::Tunnel.any_instance.expects(:auth)
        run_cmd("node tunnel auth adfhauf98q7rtqhfkajf")
      end

      def test_auth_no_token
        ShopifyCli::Tunnel.any_instance.expects(:auth).never
        run_cmd("node tunnel auth")
      end

      def test_start
        ShopifyCli::Tunnel.any_instance.expects(:start)
        run_cmd("node tunnel start")
      end

      def test_stop
        ShopifyCli::Tunnel.any_instance.expects(:stop)
        run_cmd("node tunnel stop")
      end
    end
  end
end
