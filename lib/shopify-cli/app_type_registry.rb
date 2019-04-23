require 'shopify_cli'

module ShopifyCli
  class AppTypeRegistry
    class << self
      def register(identifier, klass)
        app_types[identifier] = klass
      end

      def build(identifier, handle, ctx)
        app_types[identifier].call(handle, ctx)
        ShopifyCli::Project.write(ctx, identifier)
      end

      def each(&enumerator)
        app_types.each(&enumerator)
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
