# frozen_string_literal: true

module Extension
  class Command
    class Create < ShopifyCLI::Command::SubCommand
      prerequisite_task :ensure_authenticated

      recommend_default_ruby_range

      options do |parser, flags|
        parser.on("--name=NAME") { |name| flags[:name] = name }
        parser.on("--template=TEMPLATE") { |template| flags[:template] = template }
        parser.on("--type=TYPE") { |type| flags[:type] = type.upcase }
        parser.on("--api-key=KEY") { |key| flags[:api_key] = key.downcase }
        parser.on("--getting-started") { flags[:getting_started] = true }
      end

      def call(args, _)
        with_create_form(args) do |form, message_for_extension|
          if Dir.exist?(form.directory_name)
            @ctx.abort(message_for_extension["create.errors.directory_exists", form.directory_name])
          end

          ShopifyCLI::Result.success(supports_development_server?(form.type.identifier))
            .then { |supported| create_extension(supported, form) }
            .then { notify_success(form, message_for_extension) }
            .unwrap { |err| @ctx.puts(message_for_extension["create.try_again"]) unless err.nil? }
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
        Models::DevelopmentServerRequirements.supported?(type)
      end

      def create_extension(supported, form)
        if supported
          use_new_create_flow(form)
        else
          use_legacy_flow(form)
        end
        ShopifyCLI::Result.success(nil)
      end

      def use_new_create_flow(form)
        Tasks::ExecuteCommands.create(
          root_dir: form.directory_name,
          template: form.template,
          type: form.type.identifier.downcase,
          context: @ctx,
        )
          .then { |output| @ctx.puts(output) }
          .unwrap do |error|
            raise ShopifyCLI::Abort, error.message unless error.nil?
          end

        @ctx.chdir(form.directory_name)
        write_env_file(form)
      rescue => error
        @ctx.debug(error)
        raise error
      end

      def use_legacy_flow(form)
        if form.type.create(form.directory_name, @ctx, getting_started: options.flags[:getting_started])
          write_env_file(form)
        else
          raise StandardError
        end
      end

      def write_env_file(form)
        ExtensionProject.write_cli_file(context: @ctx, type: form.type.identifier)
        ExtensionProject.write_env_file(
          context: @ctx,
          title: form.name,
          api_key: form.app.api_key,
          api_secret: form.app.secret
        )
      end

      def notify_success(form, msg)
        @ctx.puts(msg["create.ready_to_start", form.directory_name, form.name])
        @ctx.puts(msg["create.learn_more", form.type.name])
      end
    end
  end
end
