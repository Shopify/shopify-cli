# frozen_string_literal: true

module Extension
  module Commands
    class Register < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--api_key=KEY') { |key| flags[:api_key] = key.downcase }
      end

      def call(args, command_name)
        @project = ExtensionProject.current

        CLI::UI::Frame.open(Content::Register::FRAME_TITLE) do
          @ctx.abort(Content::Register::ALREADY_REGISTERED) if @project.registered?

          with_register_form(args) do |form|
            should_continue = confirm_registration
            registration = should_continue ? register_extension(form.app) : @ctx.abort(Content::Register::CONFIRM_ABORT)

            update_project_files(form.app, registration)

            @ctx.puts(Content::Register::SUCCESS % @project.title)
            @ctx.puts(Content::Register::SUCCESS_INFO)
          end
        end
      end

      def self.help
        <<~HELP
          Connect your local extension to a Shopify app.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} register}}
            Options:
              {{command:--api_key=API_KEY}} The API key used to connect an app to the extension. This can be found on the app page on Partners Dashboard.
        HELP
      end

      private

      def with_register_form(args)
        form = Forms::Register.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        yield form
      end

      def confirm_registration
        @ctx.puts(Content::Register::CONFIRM_INFO % @project.extension_type.name)
        CLI::UI::Prompt.confirm(Content::Register::CONFIRM_QUESTION)
      end

      def register_extension(app)
        @ctx.puts(Content::Register::WAITING_TEXT)

        Tasks::CreateExtension.call(
          context: @ctx,
          api_key: app.api_key,
          type: @project.extension_type.identifier,
          title: @project.title,
          config: {},
          extension_context: @project.extension_type.extension_context(@ctx)
        )
      end

      def update_project_files(app, registration)
        ExtensionProject.write_env_file(
          context: @ctx,
          api_key: app.api_key,
          api_secret: app.secret,
          registration_id: registration.id,
          title: @project.title
        )
      end
    end
  end
end
