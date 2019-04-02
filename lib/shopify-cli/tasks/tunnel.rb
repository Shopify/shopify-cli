require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Tunnel < ShopifyCli::Task
      def call(ctx, *)
        ctx.puts('success!')
      end
    end
  end
end
