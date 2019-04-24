require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class AppType < ShopifyCli::Task
      class << self
        def description
          raise NotImplementedError
        end
      end

      def call(*args)
        @name = args.shift
        @ctx = args.shift
        @dir = File.join(Dir.pwd, @name)
        build
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
