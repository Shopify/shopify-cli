# frozen_string_literal: true

module Script
  module Commands
    class Deploy < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--api_key=APIKEY') { |t| flags[:api_key] = t }
        parser.on('--force') { |t| flags[:force] = t }
      end

      def call(args, _name)
        form = Forms::Deploy.ask(@ctx, args, options.flags)
        project = ScriptProject.current

        return @ctx.puts(self.class.help) unless form && ScriptProject::SUPPORTED_LANGUAGES.include?(project.language)

        Layers::Application::DeployScript.call(
          ctx: @ctx,
          language: project.language,
          extension_point_type: project.extension_point_type,
          script_name: project.script_name,
          api_key: form.api_key,
          force: form.force
        )
        @ctx.puts(@ctx.message('script.deploy.script_deployed', api_key: form.api_key))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.deploy.error.operation_failed'))
      end

      def self.help
        ShopifyCli::Context.message('script.deploy.help', ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message('script.deploy.extended_help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
