# frozen_string_literal: true

module Extension
  module Models
    module SpecificationHandlers
      class Default
        attr_reader :specification

        def initialize(specification)
          @specification = specification
        end

        def identifier
          specification.identifier.to_s.upcase
        end

        def graphql_identifier
          specification.graphql_identifier.to_s.upcase
        end

        def name
          message("name") || specification.name
        end

        def tagline
          message("tagline") || ""
        end

        def config(context)
          argo.config(context)
        end

        def create(directory_name, context)
          argo.create(directory_name, identifier, context)
        end

        def extension_context(_context)
          nil
        end

        def valid_extension_contexts
          []
        end

        def choose_port?(context)
          argo_runtime(context).accepts_port?
        end

        def establish_tunnel?(context)
          argo_runtime(context).accepts_tunnel_url?
        end

        def serve(context:, port:, tunnel_url:)
          Features::ArgoServe.new(
            specification_handler: self,
            argo_runtime: argo_runtime(context),
            context: context,
            port: port,
            tunnel_url: tunnel_url,
          ).call
        end

        def renderer_package(context)
          argo.renderer_package(context)
        end

        def argo_runtime(context)
          @argo_runtime ||= Features::ArgoRuntime.new(
            renderer: renderer_package(context),
            cli: cli_package(context),
          )
        end

        def cli_package(context)
          cli_package_name = specification.features.argo&.cli_package_name
          return unless cli_package_name

          js_system = ShopifyCli::JsSystem.new(ctx: context)
          Tasks::FindNpmPackages.exactly_one_of(cli_package_name, js_system: js_system)
            .unwrap { |_e| context.abort(context.message("errors.package_not_found", cli_package_name)) }
        end

        protected

        def argo
          Features::Argo.new(
            git_template: specification.features.argo.git_template,
            renderer_package_name: specification.features.argo.renderer_package_name
          )
        end

        private

        def message(key, *params)
          return unless messages.key?(key.to_sym)
          messages[key.to_sym] % params
        end

        def messages
          @messages ||= Messages::TYPES[identifier.downcase.to_sym] || {}
        end
      end
    end
  end
end
