# frozen_string_literal: true

module Extension
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on('--name=NAME') { |name| flags[:name] = name }
        parser.on('--type=TYPE') { |type| flags[:type] = type.upcase  }
        parser.on('--api-key=KEY') { |key| flags[:api_key] = key.downcase }
      end

      def call(args, _)
        with_create_form(args) do |form|
          build(form.directory_name)

          ExtensionProject.write_project_files(
            context: @ctx,
            api_key: form.app.api_key,
            api_secret: form.app.secret,
            title: form.name,
            type: form.type.identifier
          )

          @ctx.puts('{{*}} ' + Content::Create::READY_TO_START % form.name)
          @ctx.puts('{{*}} ' + Content::Create::LEARN_MORE % form.type.name)
        end
      end

      def self.help
        <<~HELP
          Create a new app extension.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} create extension <name>}}
            Options:
              {{command:--api_key=API_KEY}} The API key used to associate an app to the extension. This can be found on the app page on Partners Dashboard.
              {{command:--type=TYPE}} The type of extension you would like to create.
              {{command:--name=NAME}} The name of your extension (40 characters).”
        HELP
      end

      private

      def with_create_form(args)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        yield form
      end

      def build(name)
        ShopifyCli::Git.clone('https://github.com/Shopify/shopify-app-extension-template.git', name, ctx: @ctx)
        ShopifyCli::Core::Finalize.request_cd(name)
        @ctx.root = File.join(@ctx.root, name)

        begin
          @ctx.rm_r('.git')
        rescue Errno::ENOENT => e
          @ctx.debug(e)
        end

        JsDeps.install(@ctx)
      end
    end
  end
end
