# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class ConvertServerConfig
      include SmartProperties

      property! :api_key, accepts: String
      property! :context, accepts: ShopifyCLI::Context
      property! :hash, accepts: Hash
      property! :port, accepts: Integer
      property! :registration_uuid, accepts: String
      property  :resource_url, accepts: String
      property! :store, accepts: String
      property! :title, accepts: String
      property  :tunnel_url, accepts: String
      property! :type, accepts: String
      property  :metafields, accepts: Array

      DEFAULT_BUILD_DIR = "build"

      def self.call(*args)
        new(*args).call
      end

      def call
        context.abort(context.message("tasks.errors.parse_error")) if hash.nil?

        renderer = Models::ServerConfig::DevelopmentRenderer.find(type)
        extension = Models::ServerConfig::Extension.new(
          uuid: registration_uuid,
          type: type,
          user: Models::ServerConfig::User.new,
          development: Models::ServerConfig::Development.new(
            build_dir: hash.dig("development", "build_dir") || DEFAULT_BUILD_DIR,
            renderer: renderer,
            entries: Models::ServerConfig::DevelopmentEntries.new(
              main: hash.dig("development", "entries", "main") || determine_default_entry_main(project_directory),
            )
          ),
          extension_points: hash.dig("extension_points"),
          capabilities: Models::ServerConfig::Capabilities.new(
            network_access: hash.dig("capabilities", "network_access") || false
          ),
          version: renderer ? version(renderer.name, context) : nil,
          title: title,
          metafields: metafields
        )

        unless resource_url.nil?
          extension.development.resource = Models::ServerConfig::DevelopmentResource.new(url: resource_url)
        end
        server_config = Models::ServerConfig::Root.new(
          extensions: [extension],
          port: port,
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

      private

      def determine_default_entry_main(project_directory)
        Dir.chdir(project_directory) do
          Dir["src/*"].lazy.grep(/index.[jt]sx?/).first
        end
      end

      def project_directory
        ExtensionProject.current.directory
      end
    end
  end
end
