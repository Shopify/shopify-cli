# frozen_string_literal: true

module Extension
  module Commands
    class Register < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--api_key=KEY') { |key| flags[:api_key] = key.downcase }
      end

      def call(args, command_name)
        @project = ExtensionProject.current

        CLI::UI::Frame.open(@ctx.message('register.frame_title')) do
          @ctx.abort(@ctx.message('register.already_registered')) if @project.registered?

          with_register_form(args) do |form|
            should_continue = confirm_registration(form.app)
            registration = should_continue ? register_extension(form.app) : @ctx.abort(@ctx.message('register.confirm_abort'))

            update_project_files(form.app, registration)

            @ctx.puts(@ctx.message('register.success', @project.title, form.app.title))
            @ctx.puts(@ctx.message('register.success_info'))
          end
        end
      end

      def self.help
        <<~HELP
        Register your local extension to a Shopify app
            Usage: {{command:#{ShopifyCli::TOOL_NAME} register}}
            Options:
              {{command:--api_key=API_KEY}} The API key used to register an app with the extension. This can be found on the app page on Partners Dashboard.
        HELP
      end

      private

      def with_register_form(args)
        form = Forms::Register.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        yield form
      end

      def confirm_registration(app)
        @ctx.puts(@ctx.message('register.confirm_info', @project.extension_type.name))
        CLI::UI::Prompt.confirm(@ctx.message('register.confirm_question', app.title))
      end

      def register_extension(app)
        @ctx.puts(@ctx.message('register.waiting_text'))

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
