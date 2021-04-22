# frozen_string_literal: true

module Extension
  class Command
    class Create < ShopifyCli::SubCommand
      prerequisite_task :ensure_authenticated

      options do |parser, flags|
        parser.on("--name=NAME") { |name| flags[:name] = name }
        parser.on("--type=TYPE") { |type| flags[:type] = type.upcase }
        parser.on("--api-key=KEY") { |key| flags[:api_key] = key.downcase }
      end

      def call(args, _)
        with_create_form(args) do |form|
          if Dir.exist?(form.directory_name)
            @ctx.abort(@ctx.message("create.errors.directory_exists", form.directory_name))
          end

          ShopifyCli::IdentityAuth.authenticated?(@ctx)

          if form.type.create(form.directory_name, @ctx)
            ExtensionProject.write_cli_file(context: @ctx, type: form.type.identifier)
            ExtensionProject.write_env_file(
              context: @ctx,
              title: form.name,
              api_key: form.app.api_key,
              api_secret: form.app.secret
            )

            @ctx.puts(@ctx.message("create.ready_to_start", form.directory_name, form.name))
            @ctx.puts(@ctx.message("create.learn_more", form.type.name))
          else
            @ctx.puts(@ctx.message("create.try_again"))
          end
        end
      end

      def self.help
        @ctx.message("create.help", ShopifyCli::TOOL_NAME)
      end

      private

      def with_create_form(args)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        yield form
      end
    end
  end
end
