# frozen_string_literal: true

module Script
  module Commands
    class Deploy < ShopifyCli::Command
      OPERATION_FAILED_MESSAGE = "Script not deployed."
      OPERATION_SUCCESS_MESSAGE = "{{v}} Script deployed to app (API key: %{api_key})."

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
        @ctx.puts(format(OPERATION_SUCCESS_MESSAGE, api_key: form.api_key))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: OPERATION_FAILED_MESSAGE)
      end

      def self.help
        <<~HELP
        Build the script and deploy it to app.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy --API_key=<API_key> [--force]}}
        HELP
      end
    end
  end
end
