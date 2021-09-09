# frozen_string_literal: true

module Extension
  module Models
    class DevelopmentServer
      include SmartProperties

      property! :executable, converts: :to_s, default: File.expand_path(
        "../../../../../ext/shopify-cli/shopify-extensions", __FILE__
      )

      def create
        raise NotImplementedError
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
