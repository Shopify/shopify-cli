# frozen_string_literal: true

module Script
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on("--name=NAME") { |name| flags[:name] = name }
        parser.on("--api=SCRIPT_API_NAME") { |api| flags[:api] = api }
        parser.on("--language=LANGUAGE") { |language| flags[:language] = language }
        parser.on("--no-config-ui") { |no_config_ui| flags[:no_config_ui] = no_config_ui }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        unless !form.name.empty? && form.api && form.language
          return @ctx.puts(self.class.help)
        end

        project = Layers::Application::CreateScript.call(
          ctx: @ctx,
          language: form.language,
          script_name: form.name,
          extension_point_type: form.api,
          no_config_ui: options.flags.key?(:no_config_ui)
        )
        @ctx.puts(@ctx.message("script.create.change_directory_notice", project.script_name))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message("script.create.error.operation_failed"))
      end

      def self.help
        allowed_values = Script::Layers::Application::ExtensionPoints.types.map { |type| "{{cyan:#{type}}}" }
        ShopifyCli::Context.message("script.create.help", ShopifyCli::TOOL_NAME, allowed_values.join(", "))
      end
    end
  end
end
