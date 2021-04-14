# frozen_string_literal: true
require "project_types/node/test_helper"

module Node
  module Commands
    class ConnectTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      def test_can_connect
        context = ShopifyCli::Context.new

        ShopifyCli::Project.stubs(:has_current?).returns(false)
        ShopifyCli::Connect.any_instance.expects(:default_connect)
          .with("node")
          .returns("node-app")
        context.expects(:done)
          .with(context.message("node.connect.connected", "node-app"))

        Node::Command::Connect.new(context).call
      end

      def test_warns_if_in_production
        context = ShopifyCli::Context.new

        context.expects(:puts)
          .with(context.message("node.connect.production_warning"))
        ShopifyCli::Connect.any_instance.expects(:default_connect)
          .with("node")
          .returns("node-app")
        context.expects(:done)
          .with(context.message("node.connect.connected", "node-app"))

        Node::Command::Connect.new(context).call
      end
    end
  end
end
