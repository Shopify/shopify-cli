# frozen_string_literal: true

require 'project_types/script/test_helper'

module Script
  module Commands
    class EnableTest < MiniTest::Test
      def setup
        super
        @cmd = Enable
        @cmd.ctx = @context
        @configuration = '{}'
        @ep_type = 'discount'
        @script_name = 'script'
        @api_key = 'key'
        @shop_domain = 'shop.myshopify.com'
        @script_project = TestHelpers::FakeScriptProject.new(
          language: @language,
          extension_point_type: @ep_type,
          script_name: @script_name
        )
        ScriptProject.stubs(:current).returns(@script_project)
      end

      def test_calls_application_enable
        Script::Layers::Application::EnableScript.expects(:call).with(
          ctx: @context,
          api_key: @api_key,
          shop_domain: @shop_domain,
          configuration: @configuration,
          extension_point_type: @ep_type,
          title: @script_name
        )

        @context
          .expects(:puts)
          .with(@context.message(
            'script.enable.script_enabled',
            api_key: @api_key,
            shop_domain: @shop_domain,
            type: @ep_type.capitalize,
            title: @script_name
          ))

        @context
          .expects(:puts)
          .with(@context.message('script.enable.info'))

        capture_io do
          perform_command
        end
      end

      def test_help
        ShopifyCli::Context
          .expects(:message)
          .with('script.enable.help', ShopifyCli::TOOL_NAME)
        Script::Commands::Enable.help
      end

      def test_extended_help
        ShopifyCli::Context
          .expects(:message)
          .with('script.enable.extended_help', ShopifyCli::TOOL_NAME)
        Script::Commands::Enable.extended_help
      end

      def test_calls_application_enable_error
        Script::Layers::Application::EnableScript.expects(:call).with(
          ctx: @context,
          api_key: @api_key,
          shop_domain: @shop_domain,
          configuration: @configuration,
          extension_point_type: @ep_type,
          title: @script_name
        ).raises(StandardError)

        @context
          .expects(:puts)
          .with(@context.message(
            'script.enable.script_enabled',
            api_key: @api_key,
            shop_domain: @shop_domain,
            type: @ep_type.capitalize,
            title: @script_name
          ))
          .never

        @context
          .expects(:puts)
          .with(@context.message('script.enable.info'))
          .never

        assert_raises StandardError do
          capture_io do
            perform_command
          end
        end
      end

      private

      def perform_command
        run_cmd("enable --api_key=#{@api_key} --shop_domain=#{@shop_domain}")
      end
    end
  end
end
