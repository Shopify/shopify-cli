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
        ShopifyCLI::Core::Monorail.stubs(:enabled?).returns(false)
      end

      def test_can_connect_if_not_in_project
        ShopifyCLI::Project.stubs(:has_current?).returns(false)

        ShopifyCLI::Connect.any_instance.expects(:default_connect).with("php").returns("php-app")
        ShopifyCLI::Context.any_instance.expects(:message).with("php.connect.connected", "php-app")

        run_cmd("php connect")
      end

      def test_warns_if_in_production
        mock_project = mock
        mock_project.expects(:env).returns({ "DUMMY_ENV_VAR" => "Dummy Value" })

        ShopifyCLI::Project.stubs(:has_current?).returns(true)
        ShopifyCLI::Project.stubs(:current).returns(mock_project)

        ShopifyCLI::Connect.any_instance.expects(:default_connect).with("php").returns("php-app")
        ShopifyCLI::Context.any_instance.expects(:message).with("php.connect.production_warning")
        ShopifyCLI::Context.any_instance.expects(:message).with("php.connect.connected", "php-app")

        run_cmd("php connect")
      end
    end
  end
end
