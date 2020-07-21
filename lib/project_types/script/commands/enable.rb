# frozen_string_literal: true

module Script
  module Commands
    class Enable < ShopifyCli::Command
      prerequisite_task :ensure_env

      def call(_args, _name)
        project = ScriptProject.current
        api_key = project.env[:api_key]
        shop_domain = project.env[:shop]

        Layers::Application::EnableScript.call(
          ctx: @ctx,
          api_key: api_key,
          shop_domain: shop_domain,
          configuration: { entries: [] },
          extension_point_type: project.extension_point_type,
          title: project.script_name
        )
        @ctx.puts(@ctx.message(
          'script.enable.script_enabled',
          api_key: api_key,
          shop_domain: shop_domain,
          type: project.extension_point_type.capitalize,
          title: project.script_name
        ))
        @ctx.puts(@ctx.message('script.enable.info'))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.enable.error.operation_failed'))
      end

      def self.help
        ShopifyCli::Context.message('script.enable.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
