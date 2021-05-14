# frozen_string_literal: true

module Extension
  module Models
    module SpecificationHandlers
      class Argo < Default
        CLI_PACKAGE_NAME = "@shopify/argo-admin-cli"

        def choose_port?(context)
          cli_compatibility(context).accepts_port?
        end

        def establish_tunnel?(context)
          cli_compatibility(context).accepts_tunnel_url?
        end

        def serve(context:, port:, tunnel_url:)
          Features::ArgoServe.new(specification_handler: self, cli_compatibility: cli_compatibility(context),
          context: context, port: port, tunnel_url: tunnel_url).call
        end

        def cli_compatibility(context)
          @cli_compatibility ||= Features::ArgoCliCompatibility.new(renderer_package: renderer_package(context),
          installed_cli_package: installed_cli_package(context))
        end

        def installed_cli_package(context)
          js_system = ShopifyCli::JsSystem.new(ctx: context)
          Tasks::FindNpmPackages.exactly_one_of(CLI_PACKAGE_NAME, js_system: js_system)
            .unwrap { |_e| context.abort(context.message("errors.package_not_found", CLI_PACKAGE_NAME)) }
        end
      end
    end
  end
end
