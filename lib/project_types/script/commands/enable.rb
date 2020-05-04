# frozen_string_literal: true

module Script
  module Commands
    class Enable < ShopifyCli::Command
      OPERATION_FAILED_MESSAGE = "Can't enable script."
      OPERATION_SUCCESS_MESSAGE = "{{v}} Script enabled. %{type} script %{title} in app (API key: %{api_key}) "\
                                  "is turned on in development store {{green:%{shop_domain}}}"

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
        @ctx.puts(format(
                    OPERATION_SUCCESS_MESSAGE,
                    api_key: form.api_key,
                    shop_domain: form.shop_domain,
                    type: project.extension_point_type.capitalize,
                    title: project.script_name
                  ))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: OPERATION_FAILED_MESSAGE)
      end

      def self.help
        <<~HELP
        Turn on script in development store.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} enable --API_key=<API_key> --shop_domain=<my_store.myshopify.com>}}
        HELP
      end
    end
  end
end
