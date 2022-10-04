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

        def create(directory_name, context, **_args)
          argo.create(directory_name, identifier, context)
        end

        def extension_context(_context)
          nil
        end

        def valid_extension_contexts
          []
        end

        def choose_port?(context)
          return true if supports_development_server?
          argo_runtime(context).supports?(:port)
        end

        def establish_tunnel?(context)
          return true if supports_development_server?
          argo_runtime(context).supports?(:public_url)
        end

        def serve(**options)
          context = options[:context]
          port = options[:port]
          tunnel_url = options[:tunnel_url]
          resource_url = options[:resource_url]

          Features::ArgoServe.new(
            specification_handler: self,
            argo_runtime: argo_runtime(context),
            context: context,
            port: port,
            tunnel_url: tunnel_url,
            resource_url: resource_url
          ).call
        end

        def renderer_package(context)
          argo.renderer_package(context)
        end

        def argo_runtime(context)
          return if supports_development_server?

          @argo_runtime ||= Features::ArgoRuntime.find(
            cli_package: cli_package(context),
            identifier: identifier
          )
        end

        def cli_package(context)
          cli_package_name = specification.features.argo&.cli_package_name
          return unless cli_package_name

          js_system = ShopifyCLI::JsSystem.new(ctx: context)
          Tasks::FindNpmPackages.exactly_one_of(cli_package_name, js_system: js_system)
            .unwrap { |_e| context.abort(context.message("errors.package_not_found", cli_package_name)) }
        end

        def message_for_extension(key, *params)
          override_key = "overrides.#{key}"
          key_parts = override_key.split(".").map(&:to_sym)
          if (str = messages.dig(*key_parts))
            str % params
          else
            ShopifyCLI::Context.message(key, *params)
          end
        end

        def supplies_resource_url?
          false
        end

        def build_resource_url(shop)
          raise NotImplementedError
        end

        def server_config_path(base_dir = Dir.pwd)
          File.join(base_dir, server_config_file)
        end

        def server_config_file
          "extension.config.yml"
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

        def supports_development_server?
          Models::DevelopmentServerRequirements.supported?(identifier)
        end
      end
    end
  end
end
