# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class TunnelTest < MiniTest::Test
      def setup
        super
        ShopifyCli::Tasks::EnsureProjectType.expects(:call).with(@context, :rails)
      end

      def test_auth
        ShopifyCli::Tunnel.any_instance.expects(:auth)
        run_cmd("rails tunnel auth adfhauf98q7rtqhfkajf")
      end

      def test_auth_no_token
        ShopifyCli::Tunnel.any_instance.expects(:auth).never
        run_cmd("rails tunnel auth")
      end

      def test_start
        ShopifyCli::Tunnel.any_instance.expects(:start)
        run_cmd("rails tunnel start")
      end

      def test_stop
        ShopifyCli::Tunnel.any_instance.expects(:stop)
        run_cmd("rails tunnel stop")
      end
    end
  end
end
