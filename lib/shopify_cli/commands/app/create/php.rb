module ShopifyCLI
  module Commands
    class App
      class Create
        class PHP < ShopifyCLI::Command::AppSubCommand
          options do |parser, flags|
            parser.on("--name=NAME") { |name| flags[:title] = name }
            parser.on("--organization-id=ID") { |organization_id| flags[:organization_id] = organization_id }
            parser.on("--store=MYSHOPIFYDOMAIN") { |url| flags[:shop_domain] = url }
            parser.on("--type=APPTYPE") { |type| flags[:type] = type }
            parser.on("--verbose") { flags[:verbose] = true }
          end

          def call(*)
            Services::App::Create::PHPService.call(
              name: options.flags[:name],
              organization_id: options.flags[:organization_id],
              shop_domain: options.flags[:shop_domain],
              type: options.flags[:type],
              verbose: !options.flags[:verbose].nil?,
              context: @ctx
            )
          end

          def self.help
            ShopifyCLI::Context.message("core.app.create.php.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
          end
        end
      end
    end
  end
end
