# frozen_string_literal: true
require "project_types/php/test_helper"

module PHP
  module Commands
    class ConnectTest < Minitest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include TestHelpers::FakeFS

      def setup
        super
        ShopifyCli::Core::Monorail.stubs(:enabled?).returns(false)
      end

      def test_can_connect
        ShopifyCli::Project.stubs(:has_current?).returns(false)
        ShopifyCli::Commands::Connect.any_instance.expects(:default_connect).with(:php).returns("php-app")
        ShopifyCli::Context.any_instance.expects(:message).with("php.connect.connected", "php-app")

        run_cmd("connect php")
      end

      def test_warns_if_in_production
        mock_project = mock
        mock_project.expects(:env).returns({ "DUMMY_ENV_VAR" => "Dummy Value" })

        ShopifyCli::Project.expects(:current_project_type).returns(:php)
        ShopifyCli::Project.stubs(:has_current?).returns(true)
        ShopifyCli::Project.stubs(:current).returns(mock_project)

        ShopifyCli::Commands::Connect.any_instance.expects(:default_connect).with(:php).returns("php-app")
        ShopifyCli::Context.any_instance.expects(:message).with("php.connect.production_warning")
        ShopifyCli::Context.any_instance.expects(:message).with("php.connect.connected", "php-app")

        run_cmd("connect php")
      end
    end
  end
end
