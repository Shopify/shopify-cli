# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module Converters
      module ServerConfigConverter
        def self.from_hash(hash, type)
          context.abort(context.message("tasks.errors.parse_error")) if hash.nil?

          project = ExtensionProject.current

          extension = Models::ServerConfig::Extension.new(
            uuid: project.registration_uuid,
            type: type.upcase,
            user: Models::ServerConfig::User.new,
            development: Models::ServerConfig::Development.new(
              build_dir: hash.dig("development", "build_dir"),
              renderer: Models::ServerConfig::DevelopmentRenderer.find(type),
              entries: Models::ServerConfig::DevelopmentEntries.new(
                main: hash.dig("development", "entries", "main")
              )
            )
          )

          Models::ServerConfig::Root.new(extensions: [extension])
        end
      end
    end
  end
end
