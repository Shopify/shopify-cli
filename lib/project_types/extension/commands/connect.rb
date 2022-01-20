# frozen_string_literal: true
module Extension
  class Command
    class Connect < ExtensionCommand
      prerequisite_task :ensure_authenticated

      options do |parser, flags|
        parser.on("--print") { |t| flags[:print] = t }
      end

      def call(args, _)
        with_connect_form(args) do |form|
          api_key = form.app.api_key
          api_secret = form.app.secret
          registration_id = form.registration.id
          if options.flags.key?(:print)
            @ctx.puts(<<~ENV)
              API_KEY=#{api_key}
              API_SECRET=#{api_secret}
              EXTENSION_ID=#{registration_id}
            ENV
          end
          ExtensionProject.write_env_file(
            context: @ctx,
            api_key: api_key,
            api_secret: api_secret,
            registration_id: registration_id,
            registration_uuid: form.registration.uuid,
            title: form.registration.title
          )
          @ctx.done(@ctx.message("connect.connected", form.app.title, form.registration.title))
        end
      end

      def self.help
        ShopifyCLI::Context.new.message("connect.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      private

      def with_connect_form(args)
        form = Forms::Connect.ask(@ctx, args, { type: specification_handler.identifier.downcase })
        return @ctx.puts(self.class.help) if form.nil?

        yield form
      end
    end
  end
end
