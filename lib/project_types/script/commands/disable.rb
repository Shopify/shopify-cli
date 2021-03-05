# frozen_string_literal: true

module Script
  module Commands
    class Disable < ShopifyCli::Command
      def call(_args, _name)
        ShopifyCli::Tasks::EnsureEnv.call(@ctx, required: [:api_key, :secret, :shop])
        project = ScriptProject.current
        Layers::Application::DisableScript.call(
          ctx: @ctx,
          api_key: project.env[:api_key],
          shop_domain: project.env[:shop],
          extension_point_type: project.extension_point_type
        )
        @ctx.puts(@ctx.message("script.disable.script_disabled"))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message("script.disable.error.operation_failed"))
      end

      def self.help
        ShopifyCli::Context.message("script.disable.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
