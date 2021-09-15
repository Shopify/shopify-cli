# frozen_string_literal: true

module Extension
  module Models
    class DevelopmentServer
      class DevelopmentServerError < StandardError; end

      include SmartProperties

      EXECUTABLE_PATH = "../../../../../ext/shopify-cli/shopify-extensions/shopify-extensions"

      property! :executable, converts: :to_s, default: File.expand_path(EXECUTABLE_PATH, __FILE__)

      def create(server_config)
        CLI::Kit::System.capture3(executable, "create", "-", stdin_data: server_config.to_yaml)
      rescue StandardError => error
        raise error
      end

      def build(server_config)
        _, error, pid = CLI::Kit::System.capture3(executable, "build", "-", stdin_data: server_config.to_yaml)
        return if pid.success?
        raise DevelopmentServerError, error
      end

      def serve
        raise NotImplementedError
      end

      def version
        raise NotImplementedError
      end
    end
  end
end
