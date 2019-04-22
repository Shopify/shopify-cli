require 'shopify_cli'

module ShopifyCli
  class CommandRegistry < CLI::Kit::CommandRegistry
    def initialize(default:, contextual_resolver: nil, task_registry: nil, ctx: nil)
      @ctx = ctx || ShopifyCli::Context.new
      @task_registry = task_registry || ShopifyCli::Tasks::Registry.new
      super(default: default, contextual_resolver: contextual_resolver)
    end

    private

    def resolve_command(name)
      resolve_prerequisite(name)
      super
    end

    def resolve_prerequisite(name)
      @task_registry[name]&.call(@ctx)
    end
  end
end
