module ShopifyCLI
  module Commands
    class App
      class Create
        class Node < ShopifyCLI::Command::AppSubCommand
          prerequisite_task :ensure_authenticated
          prerequisite_task :ensure_git_dependency

          recommend_default_node_range
          recommend_default_ruby_range

          options do |parser, flags|
            parser.on("--name=NAME") { |t| flags[:name] = t }
            parser.on("--organization-id=ID") { |id| flags[:organization_id] = id }
            parser.on("--store-domain=MYSHOPIFYDOMAIN") { |url| flags[:store_domain] = url }
            parser.on("--type=APPTYPE") { |type| flags[:type] = type }
            parser.on("--verbose") { flags[:verbose] = true }
          end

          def call(*)
            Services::App::Create::NodeService.call(
              name: options.flags[:name],
              organization_id: options.flags[:organization_id],
              store_domain: options.flags[:store_domain],
              type: options.flags[:type],
              verbose: !options.flags[:verbose].nil?,
              context: @ctx
            )
          end

          class << self
            def help
              ShopifyCLI::Context.message("core.app.create.node.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
            end
          end
        end
      end
    end
  end
end
