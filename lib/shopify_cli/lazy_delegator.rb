require "delegate"

module ShopifyCLI
  ##
  # `LazyDelegator` defers initialization of its underlying delegatee until the
  # latter is accessed for the first time due to a method call that the
  # delegator cannot handle itself:
  #
  #   result = LazyDelegator.new do
  #     # carry out costly operation ...
  #   end
  #
  #   result      # referencing the object itself does not result in Proc evaluation
  #   result.to_h # however, calling a method on it will result in Proc evaluation
  #
  # LazyDelegator lends itself to being subclassed in scenarios where some
  # facts are known and others are costly to compute:
  #
  #   class LazySpecificationHandler < ShopifyCLI::LazyDelegator
  #     attr_reader :identifier
  #
  #     def initialize(identifier, &initializer)
  #       super(&initializer)
  #       @identifier = identifier
  #     end
  #   end
  #
  #   handler = LazySpecificationHandler.new(:product_subscription) do
  #      # fetch specification from the Partners Dashboard API ...
  #   end
  #
  #   # Accessing identifier will not result in Proc evaluation as it is
  #   # available as an attribute of the delegator itself
  #   handler.identifier # => :product_subscription
  #
  #   # Accessing the specification will result in evaluation of the Proc
  #   # and in our example in a subsequent network call
  #   handler.specification # => <Extension::Models::Specifcation:...>
  #
  class LazyDelegator < SimpleDelegator
    def initialize(&delegatee_initializer)
      super([false, delegatee_initializer])
    end

    protected

    def __getobj__(*)
      initialized, value_or_initializer = super
      return value_or_initializer if initialized
      value_or_initializer.call.tap do |value|
        __setobj__([true, value])
      end
    end
  end
end
