module Extension
  module Models
    class LazySpecificationHandler < ShopifyCli::LazyDelegator
      attr_reader :identifier

      def initialize(identifier, &specification_handler_initializer)
        super(&specification_handler_initializer)
        @identifier = identifier
      end
    end
  end
end
