# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  module Commands
    class ConnectTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      def test_can_connect
        context = ShopifyCLI::Context.new

        ShopifyCLI::Project.expects(:has_current?).returns(false)
        ShopifyCLI::Connect.any_instance.expects(:default_connect)
          .with("rails")
          .returns("rails-app")
        context.expects(:done)
          .with(context.message("rails.connect.connected", "rails-app"))

        Rails::Command::Connect.new(context).call
      end

      def test_warns_if_in_production
        context = ShopifyCLI::Context.new

        ShopifyCLI::Project.stubs(:current_project_type).returns(:rails)
        context.expects(:puts)
          .with(context.message("rails.connect.production_warning"))
        ShopifyCLI::Connect.any_instance.expects(:default_connect)
          .with("rails")
          .returns("rails-app")
        context.expects(:done)
          .with(context.message("rails.connect.connected", "rails-app"))

        Rails::Command::Connect.new(context).call
      end
    end
  end
end
