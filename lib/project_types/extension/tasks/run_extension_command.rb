
# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class RunExtensionCommand < ShopifyCLI::Task
      include SmartProperties

      SUPPORTED_COMMANDS = [
        "create",
        "build",
        "serve",
      ]

      property! :command, accepts: SUPPORTED_COMMANDS
      property! :type, accepts: Models::DevelopmentServerRequirements::SUPPORTED_EXTENSION_TYPES
      property! :context, accepts: ShopifyCLI::Context
      property :config_file_name, accepts: String
      property :port, accepts: Integer, default: 39351
      property :resource_url, accepts: String
      property :root_dir, accepts: String
      property :template, accepts: Models::ServerConfig::Development::VALID_TEMPLATES
      property :tunnel_url, accepts: String

      def call
        ShopifyCLI::Result.success(config_file_exists?)
          .then(&method(:load_or_build_server_config))
          .then(&method(:run_command))
          .unwrap do |error|
            raise error unless error.nil?
          end
      end

      private

      def config_file_exists?
        return false if config_file_name.nil?
        project = ExtensionProject.current
        File.exist?(File.join(project.directory, config_file_name))
      end

      def load_or_build_server_config(config_file_exists)
        return merge_server_config if config_file_exists
        build_server_config
      end

      def merge_server_config
        Tasks::MergeServerConfig.call(
          context: context,
          file_name: config_file_name,
          resource_url: resource_url,
          tunnel_url: tunnel_url,
          type: type
        )
      end

      def build_server_config
        extension = Models::ServerConfig::Extension.build(
          template: template,
          type: type,
          root_dir: root_dir,
        )

        Models::ServerConfig::Root.new(port: port, extensions: [extension])
      end

      def run_command(server_config)
        case command
        when "create"
          Models::DevelopmentServer.new.create(server_config)
        when "build"
          Models::DevelopmentServer.new.build(server_config)
        when "serve"
          Models::DevelopmentServer.new.serve(context, server_config)
        else
          raise NotImplementedError
        end
      end
    end
  end
end
