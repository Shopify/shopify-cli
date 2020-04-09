# frozen_string_literal: true

module Extension
  module Commands
    class Create < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on('--title=TITLE') { |t| flags[:title] = t }
        parser.on('--type=TYPE') { |type| flags[:type] = type.downcase  }
        parser.on('--api-key=KEY') { |key| flags[:api_key] = key.downcase }
      end

      def call(args, _name)
        form = Forms::Create.ask(@ctx, args, options.flags)
        return @ctx.puts(self.class.help) if form.nil?
        build(form.title, @ctx)
        write_envfile(form)
      end

      def self.help
        <<~HELP
          Create a new app extension.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} create extension <name>}}
        HELP
      end

      private

      def build(name, ctx)
        ShopifyCli::Git.clone('https://github.com/Shopify/shopify-app-extension-template.git', name)
        ShopifyCli::Core::Finalize.request_cd(name)
        ctx.root = File.join(ctx.root, name)

        begin
          ctx.rm_r(File.join(ctx.root, '.git'))
          ctx.rm(File.join(ctx.root, 'yarn.lock'))
        rescue Errno::ENOENT => e
          ctx.debug(e)
        end

        JsDeps.install(ctx)
      end

      def write_envfile(form)
        ShopifyCli::Helpers::EnvFile.new(
          api_key: form.app["apiKey"],
          secret: form.app["apiSecretKeys"].first["secret"]
        ).write(@ctx)
      end
    end
  end
end
