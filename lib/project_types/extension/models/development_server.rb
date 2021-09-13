# frozen_string_literal: true

module Extension
  module Models
    class DevelopmentServer
      include SmartProperties

      property! :executable, converts: :to_s, default: File.expand_path(
        "../../../../../ext/shopify-cli/shopify-extensions", __FILE__
      )

      def create(server_config)
        CLI::Kit::System.capture3(executable, "create", "-", stdin_data: server_config.to_yaml)
      rescue StandardError => error
        raise error
      end

      def build
        raise NotImplementedError
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
