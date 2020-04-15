# frozen_string_literal: true

module Script
  module Commands
    class Create < ShopifyCli::SubCommand
      DIRECTORY_CHANGED_MSG = "{{v}} Changed to project directory: {{green:%{folder}}}"
      OPERATION_SUCCESS_MESSAGE = "{{v}} Script created: {{green:%{script_id}}}"
      OPERATION_FAILED_MESSAGE = "Script not created."

      options do |parser, flags|
        parser.on('--extension_point=EP_NAME') { |ep_name| flags[:extension_point] = ep_name }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        script_name = form.name
        ep_name = form.extension_point
        language = 'ts'

        return @ctx.puts(self.class.help) unless script_name && ep_name && SUPPORTED_LANGUAGES.include?(language)

        extension_point = Layers::Application::ExtensionPoints.get(ep_name)

        ScriptModule::Application::Script.create_project(
          @ctx,
          language,
          script_name,
          extension_point
        )
        ScriptModule::Presentation::DependencyInstaller.call(
          @ctx,
          language,
          extension_point,
          script_name,
          OPERATION_FAILED_MESSAGE
        )

        script = create_script_definition(language, extension_point, script_name)
        Finalize.request_cd(script_name)

        @ctx.puts(format(DIRECTORY_CHANGED_MSG, folder: script_name))
        @ctx.puts(format(OPERATION_SUCCESS_MESSAGE, script_id: script.id))
      rescue StandardError => e
        ShopifyCli::UI::ErrorHandler.pretty_print_and_raise(e, failed_op: OPERATION_FAILED_MESSAGE)
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

      private

      def create_script_definition(language, extension_point, script_name)
        script = nil
        ShopifyCli::UI::StrictSpinner.spin('Creating script') do |spinner|
          script = ScriptModule::Application::Script.create_definition(
            language,
            extension_point,
            script_name
          )
          spinner.update_title('Created script')
        end
        script
      end
    end
  end
end

