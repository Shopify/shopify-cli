# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Commands
    class ConnectTest < MiniTest::Test
      include TestHelpers::FakeUI

      SHOPIFYCLI_FILE = <<~CLI
        ---
        project_type: theme
        organization_id: 0
      CLI

      def test_can_connect_theme
        FakeFS do
          context = ShopifyCli::Context.new
          ShopifyCli::Project.expects(:has_current?).returns(false).twice

          context.expects(:done).with(context.message("theme.connect.connected", context.root))

          Theme::Command::Connect.new(context).call([], "connect")
          assert_equal SHOPIFYCLI_FILE, File.read(".shopify-cli.yml")
        end
      end

      def test_aborts_if_inside_project
        FakeFS do
          context = ShopifyCli::Context.new
          ShopifyCli::Project.expects(:has_current?).returns(true)

          ShopifyCli::Project.expects(:write).never

          assert_raises CLI::Kit::Abort do
            Theme::Command::Connect.new(context).call([], "connect")
          end
        end
      end
    end
  end
end
