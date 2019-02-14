require 'shopify_cli'

module ShopifyCli
  module EntryPoint
    class << self
      def call(args)
        command, command_name, args = ShopifyCli::Resolver.call(args)
        ShopifyCli::Executor.call(command, command_name, args)
      ensure
        ShopifyCli::Finalize.deliver!
      end
    end
  end
end
