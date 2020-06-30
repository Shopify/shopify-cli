# frozen_string_literal: true

module Script
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on('--name=NAME') { |name| flags[:name] = name }
        parser.on('--extension_point=EP_NAME') { |ep_name| flags[:extension_point] = ep_name }
      end

      def call(args, _name)
        language = 'ts'
        cur_dir = @ctx.root

        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        unless !form.name.empty? && form.extension_point && ScriptProject::SUPPORTED_LANGUAGES.include?(language)
          return @ctx.puts(self.class.help)
        end

        Layers::Application::CreateScript.call(
          ctx: @ctx,
          language: language,
          script_name: form.name,
          extension_point_type: form.extension_point
        )
        project = ScriptProject.current
        @ctx.puts(@ctx.message('script.create.changed_dir', folder: project.script_name))
        @ctx.puts(@ctx.message('script.create.script_created', script_id: project.source_file))
      rescue StandardError => e
        ScriptProject.cleanup(ctx: @ctx, script_name: form.name, root_dir: cur_dir)
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.create.error.operation_failed'))
      end

      def self.help
        ShopifyCli::Context.message('script.create.help', ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        allowed_values = Script::Layers::Application::ExtensionPoints.types.map { |type| "{{cyan:#{type}}}" }
        ShopifyCli::Context.message('script.create.extended_help', ShopifyCli::TOOL_NAME, allowed_values.join(', '))
      end
    end
  end
end
