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
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        unless !form.name.empty? && form.extension_point && ScriptProject::SUPPORTED_LANGUAGES.include?(language)
          return @ctx.puts(self.class.help)
        end

        script = Layers::Application::CreateScript.call(
          ctx: @ctx,
          language: language,
          script_name: form.name,
          extension_point_type: form.extension_point
        )
        @ctx.puts(@ctx.message('script.create.changed_dir', folder: script.name))
        @ctx.puts(@ctx.message('script.create.script_created', script_id: script.id))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.create.error.operation_failed'))
      end

      def self.help
        allowed_values = "{{cyan:discount}} and {{cyan:unit_limit_per_order}}"
        ShopifyCli::Context.message('script.create.help', ShopifyCli::TOOL_NAME, allowed_values)
      end
    end
  end
end

