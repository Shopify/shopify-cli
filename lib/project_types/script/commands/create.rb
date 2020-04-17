# frozen_string_literal: true

module Script
  module Commands
    class Create < ShopifyCli::SubCommand
      DIRECTORY_CHANGED_MSG = "{{v}} Changed to project directory: {{green:%{folder}}}"
      OPERATION_FAILED_MESSAGE = "Script not created."
      OPERATION_SUCCESS_MESSAGE = "{{v}} Script created: {{green:%{script_id}}}"

      options do |parser, flags|
        parser.on('--extension_point=EP_NAME') { |ep_name| flags[:extension_point] = ep_name }
      end

      def call(args, _name)
        language = 'ts'
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        unless form.name && form.extension_point && ScriptProject::SUPPORTED_LANGUAGES.include?(language)
          return @ctx.puts(self.class.help)
        end

        script = Layers::Application::CreateScript.call(
          ctx: @ctx,
          language: language,
          script_name: form.name,
          extension_point_type: form.extension_point
        )
        @ctx.puts(format(DIRECTORY_CHANGED_MSG, folder: script.name))
        @ctx.puts(format(OPERATION_SUCCESS_MESSAGE, script_id: script.id))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: OPERATION_FAILED_MESSAGE)
      end

      def self.help
        allowed_values = "{{cyan:discount}} and {{cyan:unit_limit_per_order}}"
        <<~HELP
        {{command:#{ShopifyCli::TOOL_NAME} create script}}: Creates a script project.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} create script <name>}}
          Options:
            {{command:--extension_point=<name>}} Extension point name. Allowed values: #{allowed_values}.
        HELP
      end
    end
  end
end

