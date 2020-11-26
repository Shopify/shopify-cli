# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Commands
    class DeployTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_deploy_command
        context = ShopifyCli::Context.new
        CLI::UI::Prompt.expects(:confirm).returns(true)
        Themekit.expects(:deploy).with(context, flags: [], env: nil).returns(true)
        context.expects(:done).with(context.message('theme.deploy.info.deployed'))

        Theme::Commands::Deploy.new(context).call
      end

      def test_can_specify_env
        context = ShopifyCli::Context.new
        CLI::UI::Prompt.expects(:confirm).returns(true)
        Themekit.expects(:deploy).with(context, flags: [], env: 'test').returns(true)
        context.expects(:done).with(context.message('theme.deploy.info.deployed'))

        command = Theme::Commands::Deploy.new(context)
        command.options.flags[:env] = 'test'
        command.call
      end

      def test_aborts_if_not_confirm
        context = ShopifyCli::Context.new
        CLI::UI::Prompt.expects(:confirm).returns(false)
        Themekit.expects(:deploy).with(context, env: nil).never

        assert_raises CLI::Kit::Abort do
          Theme::Commands::Deploy.new(context).call
        end
      end

      def test_aborts_if_errors
        context = ShopifyCli::Context.new
        CLI::UI::Prompt.expects(:confirm).returns(true)
        Themekit.expects(:deploy).with(context, flags: [], env: nil).returns(false)
        context.expects(:done).with(context.message('theme.deploy.info.deployed')).never

        assert_raises CLI::Kit::Abort do
          Theme::Commands::Deploy.new(context).call
        end
      end
    end
  end
end
