# frozen_string_literal: true

module Extension
  class Command
    class Create < ShopifyCLI::SubCommand
      DEVELOPMENT_SERVER_SUPPORTED_TYPES = [
        "checkout_ui_extension",
      ]

      prerequisite_task :ensure_authenticated

      options do |parser, flags|
        parser.on("--name=NAME") { |name| flags[:name] = name }
        parser.on("--type=TYPE") { |type| flags[:type] = type.upcase }
        parser.on("--api-key=KEY") { |key| flags[:api_key] = key.downcase }
        parser.on("--getting-started") { flags[:getting_started] = true }
      end

      def call(args, _)
        with_create_form(args) do |form, message_for_extension|
          if Dir.exist?(form.directory_name)
            @ctx.abort(message_for_extension["create.errors.directory_exists", form.directory_name])
          end

          return use_new_create_flow(form, message_for_extension) if supports_development_server?(form.type)

          if form.type.create(form.directory_name, @ctx, getting_started: options.flags[:getting_started])
            ExtensionProject.write_cli_file(context: @ctx, type: form.type.identifier)
            ExtensionProject.write_env_file(
              context: @ctx,
              title: form.name,
              api_key: form.app.api_key,
              api_secret: form.app.secret
            )

            @ctx.puts(message_for_extension["create.ready_to_start", form.directory_name, form.name])
            @ctx.puts(message_for_extension["create.learn_more", form.type.name])
          else
            @ctx.puts(message_for_extension["create.try_again"])
          end
        end
      end

      def self.help
        @ctx.message("create.help", ShopifyCLI::TOOL_NAME)
      end

      private

      def with_create_form(args)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        yield form, form.type.method(:message_for_extension)
      end

      def supports_development_server?(type)
        return false unless DEVELOPMENT_SERVER_SUPPORTED_TYPES.include?(type.identifier.downcase)
        ShopifyCLI::Shopifolk.check && ShopifyCLI::Feature.enabled?(:extension_server_beta)
      end

      def use_new_create_flow(form, msg)
        Tasks::RunExtensionCommand.new(
          root_dir: form.directory_name,
          template: form.template,
          type: form.type.identifier.downcase,
          command: "create"
        ).call

        @ctx.puts(msg["create.ready_to_start", form.directory_name, form.name])
        @ctx.puts(msg["create.learn_more", form.type.name])
      rescue => error
        @ctx.debug(error)
        @ctx.puts(msg["create.try_again"])
      end
    end
  end
end
