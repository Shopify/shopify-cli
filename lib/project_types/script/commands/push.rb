# frozen_string_literal: true

module Script
  class Command
    class Push < ShopifyCLI::Command::SubCommand
      prerequisite_task ensure_project_type: :script

      options do |parser, flags|
        parser.on("--force") { |t| flags[:force] = t }
      end

      def call(_args, _name)
        # old call to a task, to be replaced
        # fresh_env = Tasks::EnsureEnv.call(@ctx)

        # determine if we need to invoke the form
        script_project_repo = Layers::Infrastructure::ScriptProjectRepository.new(ctx: @ctx)
        script_project = script_project_repo.get
        fresh_env = !Layers::Application::ConnectApp.env_valid?(script_project: script_project)

        # We need to check to decide to invoke the form
        if fresh_env
          # first, we need to perform all the CLI actions here, within the command class
          # since we need to ask the user for input, we should actually gather this info in a form
          form = Forms::Connect.ask(@ctx, nil, options.flags)
          # second, we need to perform all the follow up logic in our application-layer, in ConnectApp.
          Layers::Application::ConnectApp.call(
            script_project_repo: script_project_repo,
            api_key: form.app["apiKey"],
            secret: form.app["apiSecretKeys"].first["secret"],
            uuid: form.uuid
          )
        end

        # third, perform the same force-check
        force = options.flags.key?(:force) || !!fresh_env

        api_key = Layers::Infrastructure::ScriptProjectRepository.new(ctx: @ctx).get.api_key
        return @ctx.puts(self.class.help) unless api_key

        Layers::Application::PushScript.call(ctx: @ctx, force: force)
        @ctx.puts(@ctx.message("script.push.script_pushed", api_key: api_key))
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
