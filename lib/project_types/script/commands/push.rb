# frozen_string_literal: true

module Script
  module Commands
    class Push < ShopifyCli::Command
      options { |parser, flags| parser.on('--force') { |t| flags[:force] = t } }

      def call(_args, _name)
        ShopifyCli::Tasks::EnsureEnv.call(@ctx, required: %i[api_key secret shop])
        project = ScriptProject.current
        api_key = project.env[:api_key]
        unless api_key && ScriptProject::SUPPORTED_LANGUAGES.include?(project.language)
          return @ctx.puts(self.class.help)
        end
        Layers::Application::PushScript.call(
          ctx: @ctx,
          language: project.language,
          extension_point_type: project.extension_point_type,
          script_name: project.script_name,
          source_file: project.source_file,
          api_key: api_key,
          force: options.flags.key?(:force),
        )
        @ctx.puts(@ctx.message('script.push.script_pushed', api_key: api_key))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.push.error.operation_failed'))
      end

      def self.help
        ShopifyCli::Context.message('script.push.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
