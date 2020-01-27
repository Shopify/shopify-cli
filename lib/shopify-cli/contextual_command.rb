require 'shopify_cli'

module ShopifyCli
  class ContextualCommand < ShopifyCli::Command
    class << self
      def has_more_context?
        true
      end

      def register_for_context(command, context_type, path)
          autoload context_type.capitalize, path + "/" + context_type.to_s
          ShopifyCli::Commands::Registry.add(->() { const_get(context_type.capitalize) }, command)
      end
    end
    private_class_method :register_for_context
  end
end
