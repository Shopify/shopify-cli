# frozen_string_literal: true

module Extension
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on('--title=TITLE') { |title| flags[:title] = title }
        parser.on('--type=TYPE') { |type| flags[:type] = type.upcase  }
        parser.on('--api-key=KEY') { |key| flags[:api_key] = key.downcase }
      end

      def call(args, _)
        with_create_form(args) do |form|
          build(form.name)

          ExtensionProject.write_project_files(
            context: @ctx,
            api_key: form.app.api_key,
            api_secret: form.app.secret,
            type: form.type
          )
        end
      end

      def self.help
        <<~HELP
          Create a new app extension.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} create extension <name>}}
        HELP
      end

      private

      def with_create_form(args)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?

        yield form
      end

      def build(name)
        ShopifyCli::Git.clone('https://github.com/Shopify/shopify-app-extension-template.git', name)
        ShopifyCli::Core::Finalize.request_cd(name)
        @ctx.root = File.join(@ctx.root, name)

        begin
          @ctx.rm_r(File.join(@ctx.root, '.git'))
          @ctx.rm(File.join(@ctx.root, 'yarn.lock'))
        rescue Errno::ENOENT => e
          @ctx.debug(e)
        end

        JsDeps.install(@ctx)
      end
    end
  end
end
