# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module Converters
      module ServerConfigConverter
        class << self
          def from_hash(api_key:, context:, hash:, type:, registration_uuid:, resource_url: nil, store:, tunnel_url:)
            context.abort(context.message("tasks.errors.parse_error")) if hash.nil?

            renderer = Models::ServerConfig::DevelopmentRenderer.find(type)

            extension = Models::ServerConfig::Extension.new(
              uuid: registration_uuid,
              type: type.upcase,
              user: Models::ServerConfig::User.new,
              development: Models::ServerConfig::Development.new(
                build_dir: hash.dig("development", "build_dir"),
                renderer: renderer,
                entries: Models::ServerConfig::DevelopmentEntries.new(
                  main: hash.dig("development", "entries", "main")
                )
              ),
              extension_points: hash.dig("extension_points"),
              version: version(renderer.name, context)
            )

            unless resource_url.nil?
              extension.development.resource = Models::ServerConfig::DevelopmentResource.new(url: resource_url)
            end

            server_config = Models::ServerConfig::Root.new(
              extensions: [extension],
              public_url: tunnel_url,
              store: store
            )

            unless api_key.nil?
              server_config.app = Models::ServerConfig::App.new(api_key: api_key)
            end
            server_config
          end

          def version(renderer, context)
            Tasks::FindPackageFromJson.call(renderer, context: context).version
          end
        end
      end
    end
  end
end
