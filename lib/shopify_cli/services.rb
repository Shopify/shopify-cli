module ShopifyCLI
  module Services
    autoload :BaseService, "shopify_cli/services/base_service"
    autoload :ReportingService, "shopify_cli/services/reporting_service"

    module App
      module Serve
        autoload :ServeService, "shopify_cli/services/app/serve/serve_service"
        autoload :NodeService, "shopify_cli/services/app/serve/node_service"
        autoload :RailsService, "shopify_cli/services/app/serve/rails_service"
        autoload :PHPService, "shopify_cli/services/app/serve/php_service"
      end

      module Create
        autoload :NodeService, "shopify_cli/services/app/create/node_service"
        autoload :RailsService, "shopify_cli/services/app/create/rails_service"
        autoload :PHPService, "shopify_cli/services/app/create/php_service"
      end

      module Deploy
        module Heroku
          autoload :NodeService, "shopify_cli/services/app/deploy/heroku/node_service"
          autoload :RailsService, "shopify_cli/services/app/deploy/heroku/rails_service"
          autoload :PHPService, "shopify_cli/services/app/deploy/heroku/php_service"
        end
      end

      module Tunnel
        autoload :StartService, "shopify_cli/services/app/tunnel/start_service"
        autoload :StopService, "shopify_cli/services/app/tunnel/stop_service"
        autoload :AuthService, "shopify_cli/services/app/tunnel/auth_service"
      end

      autoload :ConnectService, "shopify_cli/services/app/connect_service"
      autoload :OpenService, "shopify_cli/services/app/open_service"
    end
  end
end
