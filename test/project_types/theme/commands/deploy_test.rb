# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Commands
    class DeployTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_deploy_command
        context = ShopifyCli::Context.new
        Themekit.expects(:ensure_themekit_installed).with(context)
        CLI::UI::Prompt.expects(:confirm).returns(true)
        Themekit.expects(:deploy).with(context).returns(true)
        context.expects(:done).with(context.message('theme.deploy.info.deployed'))

        Theme::Commands::Deploy.new(context).call
      end

      def test_aborts_if_not_confirm
        context = ShopifyCli::Context.new
        Themekit.expects(:ensure_themekit_installed).with(context)
        CLI::UI::Prompt.expects(:confirm).returns(false)
        Themekit.expects(:deploy).with(context).never

        assert_raises CLI::Kit::Abort do
          Theme::Commands::Deploy.new(context).call
        end
      end

      def test_aborts_if_errors
        context = ShopifyCli::Context.new
        Themekit.expects(:ensure_themekit_installed).with(context)
        CLI::UI::Prompt.expects(:confirm).returns(true)
        Themekit.expects(:deploy).with(context).returns(false)
        context.expects(:done).with(context.message('theme.deploy.info.deployed')).never

        assert_raises CLI::Kit::Abort do
          Theme::Commands::Deploy.new(context).call
        end
      end
    end
  end
end
