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
        capture_io do
          perform_command
        end
      end

      private

      def perform_command
        run_cmd("enable --api_key=#{@api_key} --shop_domain=#{@shop_domain}")
      end
    end
  end
end
