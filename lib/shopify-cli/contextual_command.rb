require 'shopify_cli'

module ShopifyCli
  class ContextualCommand < ShopifyCli::Command
    class << self
      def needs_contextual_resolution?
        true
      end

      def available_in_contexts(command, context_types)
        project_context = Project.current_context
        unregister_for_context(command) unless context_types.include?(project_context)
      end

      def unavailable_in_contexts(command, context_types)
        project_context = Project.current_context
        unregister_for_context(command) if context_types.include?(project_context)
      end

      def override_in_contexts(command, context_types, path)
        project_context = Project.current_context
        if context_types.include?(project_context)
          autoload project_context.capitalize, path + "/" + project_context.to_s
          ShopifyCli::Commands::Registry.add(->() { const_get(project_context.capitalize) }, command)
        end
      end

      def unregister_for_context(command)
        ShopifyCli::Commands::Registry.add(->() { }, command)
      end
    end
  end
end
