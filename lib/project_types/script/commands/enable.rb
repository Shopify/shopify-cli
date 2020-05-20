# frozen_string_literal: true

module Script
  module Commands
    class Enable < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--api_key=APIKEY') { |t| flags[:api_key] = t }
        parser.on('--shop_domain=MYSHOPIFYDOMAIN') { |t| flags[:shop_domain] = t }
      end

      def call(args, _name)
        form = Forms::Enable.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) unless form

        project = ScriptProject.current

        Layers::Application::EnableScript.call(
          ctx: @ctx,
          api_key: form.api_key,
          shop_domain: form.shop_domain,
          configuration: '{}',
          extension_point_type: project.extension_point_type,
          title: project.script_name
        )
        @ctx.puts(@ctx.message(
          'script.enable.script_enabled',
          api_key: form.api_key,
          shop_domain: form.shop_domain,
          type: project.extension_point_type.capitalize,
          title: project.script_name
        ))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.enable.error.operation_failed'))
      end

      def self.help
        ShopifyCli::Context.message('script.enable.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
