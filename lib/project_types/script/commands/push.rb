# frozen_string_literal: true

module Script
  module Commands
    class Push < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--api_key=APIKEY') { |t| flags[:api_key] = t }
        parser.on('--force') { |t| flags[:force] = t }
      end

      def call(args, _name)
        form = Forms::Push.ask(@ctx, args, options.flags)
        project = ScriptProject.current

        return @ctx.puts(self.class.help) unless form && ScriptProject::SUPPORTED_LANGUAGES.include?(project.language)

        Layers::Application::PushScript.call(
          ctx: @ctx,
          language: project.language,
          extension_point_type: project.extension_point_type,
          script_name: project.script_name,
          source_file: project.source_file,
          api_key: form.api_key,
          force: form.force
        )
        @ctx.puts(@ctx.message('script.push.script_pushed', api_key: form.api_key))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.push.error.operation_failed'))
      end

      def self.help
        ShopifyCli::Context.message('script.push.help', ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message('script.push.extended_help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
