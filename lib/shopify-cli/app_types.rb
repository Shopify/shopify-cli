require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class AppType < ShopifyCli::Task
      include SmartProperties

      property :name
      property :ctx, accepts: ShopifyCli::Context

      class << self
        def description
          raise NotImplementedError
        end

        def serve_command
          raise NotImplementedError
        end

        def generate
          raise NotImplementedError
        end
      end

      def initialize(*)
        super
        ctx.root = File.join(ctx.root, name)
      end

      def build
        raise NotImplementedError
      end
    end
  end
end

Dir.glob(
  File.join(ShopifyCli::ROOT, './lib/shopify-cli/app_types/*.rb')
) { |f| require f }
