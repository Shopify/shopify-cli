# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module Converters
      module ServerConfigConverter
        def self.from_hash(hash:, type:, registration_uuid:, store:, tunnel_url:, resource_url: nil)
          context.abort(context.message("tasks.errors.parse_error")) if hash.nil?

          extension = Models::ServerConfig::Extension.new(
            uuid: registration_uuid,
            type: type.upcase,
            user: Models::ServerConfig::User.new,
            development: Models::ServerConfig::Development.new(
              build_dir: hash.dig("development", "build_dir"),
              renderer: Models::ServerConfig::DevelopmentRenderer.find(type),
              entries: Models::ServerConfig::DevelopmentEntries.new(
                main: hash.dig("development", "entries", "main")
              )
            ),
            extension_points: hash.dig("extension_points")
          )

          unless resource_url.nil?
            extension.development.resource = Models::ServerConfig::DevelopmentResource.new(url: resource_url)
          end

          Models::ServerConfig::Root.new(extensions: [extension], store: store, public_url: tunnel_url)
        end
      end
    end
  end
end
