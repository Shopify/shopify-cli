# frozen_string_literal: true

module Script
  class Command
    class Push < ShopifyCLI::Command::SubCommand
      prerequisite_task ensure_project_type: :script

      options do |parser, flags|
        parser.on("--force") { |t| flags[:force] = t }
        parser.on("--api-key=API_KEY") { |api_key| flags[:api_key] = api_key.gsub('"', "") }
        parser.on("--api-secret=API_SECRET") { |api_secret| flags[:api_secret] = api_secret.gsub('"', "") }
        parser.on("--uuid=UUID") do |uuid|
          flags[:uuid] = uuid.gsub('""', "")
        end
      end

      def call(_args, _name)
        project = Script::Loaders::Project.load(
          directory: Dir.pwd,
          api_key: options.flags[:api_key],
          api_secret: options.flags[:api_secret],
          uuid: options.flags[:uuid]
        )

        puts "project #{project.inspect}"
        # specification_handler = Script::Loaders::SpecificationHandler.load(project: project, context: @ctx)
        # fresh_env = Layers::Application::ConnectApp.call(ctx: @ctx)

        force = options.flags.key?(:force)
        api_key = project.env[:api_key]
        api_secret = project.env[:secret]
        uuid = project.env[:extra]["UUID"]

        return @ctx.puts(self.class.help) if !api_key && @ctx.tty?
        
        if @ctx.tty? || uuid
          Layers::Application::PushScript.call(ctx: @ctx, force: force, project: project)
          @ctx.puts(@ctx.message("script.push.script_pushed", api_key: api_key))
        else
           @ctx.puts("UUID is required to push in a CI environment")
        end
      rescue SmartProperties::InitializationError
        @ctx.puts("Script needs to be connected to an app")
      rescue StandardError => e
        msg = if api_key
          @ctx.message("script.push.error.operation_failed_with_api_key", api_key: api_key)
        else
          @ctx.message("script.push.error.operation_failed_no_api_key")
        end
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: msg)
      end

      def self.help
        ShopifyCLI::Context.message("script.push.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
