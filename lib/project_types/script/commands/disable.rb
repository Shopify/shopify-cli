# frozen_string_literal: true

module Script
  module Commands
    class Disable < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--api_key=APIKEY') { |t| flags[:api_key] = t }
        parser.on('--shop_domain=MYSHOPIFYDOMAIN') { |t| flags[:shop_domain] = t }
      end

      def call(args, _name)
        form = Forms::Enable.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) unless form

        project = ScriptProject.current
        Layers::Application::DisableScript.call(
          ctx: @ctx,
          api_key: form.api_key,
          shop_domain: form.shop_domain,
          extension_point_type: project.extension_point_type
        )
        @ctx.puts(@ctx.message('script.disable.script_disabled'))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.disable.error.operation_failed'))
      end

      def self.help
        ShopifyCli::Context.message('script.disable.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
