require 'shopify_cli'

module ShopifyCli
  class ContextualCommand < ShopifyCli::Command
    class << self
      def needs_contextual_resolution?
        true
      end

      def override_for_context(command, context_type, path)
          autoload context_type.capitalize, path + "/" + context_type.to_s
          ShopifyCli::Commands::Registry.add(->() { const_get(context_type.capitalize) }, command)
      end

      def unregister_for_context(command)
        ShopifyCli::Commands::Registry.add(->() { }, command)
      end
    end
  end
end
