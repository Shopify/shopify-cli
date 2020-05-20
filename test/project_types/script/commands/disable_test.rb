# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Commands
    class DisableTest < MiniTest::Test
      def setup
        super
        @cmd = Disable
        @cmd.ctx = @context
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
        Script::Layers::Application::DisableScript.expects(:call).with(
          ctx: @context,
          api_key: @api_key,
          shop_domain: @shop_domain,
          extension_point_type: @ep_type,
        )
        capture_io do
          perform_command
        end
      end

      private

      def perform_command
        run_cmd("disable --api_key=#{@api_key} --shop_domain=#{@shop_domain}")
      end
    end
  end
end
