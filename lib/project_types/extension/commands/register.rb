# frozen_string_literal: true

module Extension
  module Commands
    class Register < ExtensionCommand
      def call(_args, _command_name)
        CLI::UI::Frame.open(@ctx.message("register.frame_title")) do
          @ctx.abort(@ctx.message("register.already_registered")) if project.registered?

          should_continue = confirm_registration
          registration = should_continue ? register_extension : abort_not_registered

          update_project_files(registration)

          @ctx.puts(@ctx.message("register.success", project.title))
          @ctx.puts(@ctx.message("register.success_info"))
        end
      end

      def self.help
        <<~HELP
          Register your local extension to a Shopify app
              Usage: {{command:#{ShopifyCli::TOOL_NAME} register}}
        HELP
      end

      private

      def confirm_registration
        @ctx.puts(@ctx.message("register.confirm_info", extension_type.name))
        CLI::UI::Prompt.confirm(@ctx.message("register.confirm_question"))
      end

      def register_extension
        @ctx.puts(@ctx.message("register.waiting_text"))

        Tasks::CreateExtension.call(
          context: @ctx,
          api_key: app.api_key,
          type: extension_type.graphql_identifier,
          title: project.title,
          config: {},
          extension_context: extension_type.extension_context(@ctx)
        )
      end

      def update_project_files(registration)
        ExtensionProject.write_env_file(
          context: @ctx,
          api_key: app.api_key,
          api_secret: app.secret,
          registration_id: registration.id,
          title: project.title
        )
      end

      def app
        @app ||= project.app
      end

      def abort_not_registered
        @ctx.puts(@ctx.message("register.confirm_abort"))
        raise ShopifyCli::AbortSilent
      end
    end
  end
end
