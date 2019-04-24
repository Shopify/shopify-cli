require 'shopify_cli'

module ShopifyCli
  class AppTypeRegistry
    class << self
      def register(identifier, klass)
        app_types[identifier] = klass
      end

      def build(identifier, handle, ctx)
        app_types[identifier].call(handle, ctx)
      end

      def each(&enumerator)
        app_types.each(&enumerator)
      end

      def [](identifier)
        app_types[identifier]
      end

      def deregister(identifier)
        app_types.delete(identifier)
      end

      protected

      def app_types
        @app_types ||= {}
      end
    end
  end

  AppTypeRegistry.register(:node, AppTypes::Node)
  AppTypeRegistry.register(:rails, AppTypes::Rails)
end
