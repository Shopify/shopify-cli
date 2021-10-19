module ShopifyCLI
  module Commands
    class App
      class Create
        class Rails < ShopifyCLI::Command::AppSubCommand
          prerequisite_task :ensure_authenticated

          options do |parser, flags|
            parser.on("--name=NAME") { |t| flags[:title] = t }
            parser.on("--organization_id=ID") { |id| flags[:organization_id] = id }
            parser.on("--shop_domain=MYSHOPIFYDOMAIN") { |url| flags[:shop_domain] = url }
            parser.on("--type=APPTYPE") { |type| flags[:type] = type }
            parser.on("--db=DB") { |db| flags[:db] = db }
            parser.on("--rails_opts=RAILSOPTS") { |opts| flags[:rails_opts] = opts }
          end

          def call(*)
            Services::App::Create::RailsService.call(
              name: options.flags[:name],
              organization_id: options.flags[:organization_id],
              shop_domain: options.flags[:shop_domain],
              type: options.flags[:type],
              db: options.flags[:db],
              rails_opts: options.flags[:rails_opts],
              context: @ctx
            )
          end
        end
      end
    end
  end
end
