module ShopifyCli
  module Util
    class << self
      def system?
        ShopifyCli::INSTALL_DIR == ShopifyCli::ROOT
      end

      # Standard way of checking if we're using the development version of shopify (i.e., load-dev)
      def development?
        !system? && !testing?
      end

      def testing?
        ci? || ENV['TEST']
      end

      def ci?
        ENV['CI']
      end
    end
  end
end
