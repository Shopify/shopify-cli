module ShopifyCLI
  module Commands
    class App
      class Create
        class Node < ShopifyCLI::Command::AppSubCommand
          prerequisite_task :ensure_authenticated

          options do |parser, flags|
            parser.on("--name=NAME") { |t| flags[:name] = t }
            parser.on("--organization_id=ID") { |id| flags[:organization_id] = id }
            parser.on("--shop_domain=MYSHOPIFYDOMAIN") { |url| flags[:shop_domain] = url }
            parser.on("--type=APPTYPE") { |type| flags[:type] = type }
            parser.on("--verbose") { flags[:verbose] = true }
          end

          def call(*)
            Services::App::Create::NodeService.call(
              name: options.flags[:name],
              organization_id: options.flags[:organization_id],
              shop_domain: options.flags[:shop_domain],
              type: options.flags[:type],
              verbose: !options.flags[:verbose].nil?,
              context: @ctx
            )
          end
        end
      end
    end
  end
end
