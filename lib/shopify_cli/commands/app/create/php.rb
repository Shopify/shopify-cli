module ShopifyCLI
  module Commands
    class App
      class Create
        class PHP < ShopifyCLI::Command::AppSubCommand
          prerequisite_task :ensure_authenticated
          prerequisite_task :ensure_git_dependency

          options do |parser, flags|
            parser.on("--name=NAME") { |name| flags[:name] = name }
            parser.on("--organization-id=ID") { |organization_id| flags[:organization_id] = organization_id }
            parser.on("--store-domain=MYSHOPIFYDOMAIN") { |url| flags[:store_domain] = url }
            parser.on("--type=APPTYPE") { |type| flags[:type] = type }
            parser.on("--verbose") { flags[:verbose] = true }
          end

          def call(*)
            Services::App::Create::PHPService.call(
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
              ShopifyCLI::Context.message("core.app.create.php.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
            end
          end
        end
      end
    end
  end
end
