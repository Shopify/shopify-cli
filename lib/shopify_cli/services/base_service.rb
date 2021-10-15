module ShopifyCLI
  module Services
    class BaseService
      def self.call(*args, **kwargs, &block)
        new(*args, **kwargs).call(&block)
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
