require 'shopify_cli'
require 'uri'

module ShopifyCli
  module Commands
    class Create
      class Extension < ShopifyCli::SubCommand
        options do |parser, flags|
          parser.on('--type=TYPE') { |type| flags[:type] = type.downcase  }
          parser.on('--api-key=KEY') { |key| flags[:api_key] = key.downcase }
        end

        def call(args, _name)
          form = Forms::CreateExtension.ask(@ctx, args, options.flags)
          return @ctx.puts(self.class.help) if form.nil?
          build(form.name, @ctx)
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
          ShopifyCli::Tasks::Clone.call('https://github.com/Shopify/shopify-app-extension-template.git', name)
          ShopifyCli::Finalize.request_cd(name)
          ctx.root = File.join(ctx.root, name)

          begin
            ctx.rm_r(File.join(ctx.root, '.git'))
            ctx.rm(File.join(ctx.root, 'yarn.lock'))
          rescue Errno::ENOENT => e
            ctx.debug(e)
          end

          ShopifyCli::Tasks::JsDeps.call(ctx)
        end

        def write_envfile(form)
          Helpers::EnvFile.new(
            api_key: form.app["apiKey"],
            secret: form.app["apiSecretKeys"].first["secret"]
          ).write(@ctx)
        end
      end
    end
  end
end
