# frozen_string_literal: true

module Script
  class Command
    class Push < ShopifyCLI::Command::SubCommand
      prerequisite_task ensure_project_type: :script

      recommend_node(
        from: ::Script::Layers::Infrastructure::Languages::TypeScriptProjectCreator::MIN_NODE_VERSION,
        to: ShopifyCLI::Constants::SupportedVersions::Node::TO
      )
      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("--force") { |t| flags[:force] = t }
        parser.on("--api-key=API_KEY") { |api_key| flags[:api_key] = api_key.gsub('"', "") }
        parser.on("--api-secret=API_SECRET") { |api_secret| flags[:api_secret] = api_secret.gsub('"', "") }
        parser.on("--uuid=UUID") do |uuid|
          flags[:uuid] = uuid.gsub('""', "")
        end
      end

      def call(_args, _name)
        connect_to_app
        project = load_project
        push(project: project)
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e)
      end

      def push(project:)
        force = options.flags.key?(:force)
        api_key = project.env[:api_key]
        uuid = project.env[:extra]["UUID"]

        if ShopifyCLI::Environment.interactive? || (uuid && !uuid.empty?)
          Layers::Application::PushScript.call(ctx: @ctx, force: force, project: project)
          @ctx.puts(@ctx.message("script.push.script_pushed", api_key: api_key))
        else
          message = @ctx.message("script.error.missing_push_options_ci", "--uuid")
          message += @ctx.message("script.error.missing_push_options_ci_solution", ShopifyCLI::TOOL_NAME)
          raise ShopifyCLI::Abort, message
        end
      end

      def load_project
        Script::Loaders::Project.load(
          directory: Dir.pwd,
          api_key: options.flags[:api_key],
          api_secret: options.flags[:api_secret],
          uuid: options.flags[:uuid]
        )
      end

      def connect_to_app
        if ShopifyCLI::Environment.interactive?
          Layers::Application::ConnectApp.call(ctx: @ctx)
        end
      end

      def self.help
        ShopifyCLI::Context.message("script.push.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
