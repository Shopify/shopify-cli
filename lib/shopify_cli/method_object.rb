module ShopifyCLI
  ##
  # The `MethodObject` mixin can be included in any class that implements `call`
  # to ensure that
  #
  # * `call` will always return a `ShopifyCLI::Result` by prepending a module
  #   that takes care of the result wrapping and
  # * a `to_proc` method that allows instances of this class to be passed as a
  #   block.
  #
  # For convenience, this mixin also adds the corresponding class methods:
  # `call` and `to_proc`. Method and result objects pair nicely as they greatly
  # simplify the creation of complex processing chains:
  #
  #   class Serialize
  #     include MethodObject
  #
  #     def call(attrs)
  #       attrs.to_json
  #     end
  #   end
  #
  #   class Deserialize
  #     include MethodObject
  #
  #     def call(json)
  #       JSON.parse(json)
  #     end
  #   end
  #
  #   Serialize
  #     .call(firstname: "John", lastname: "Doe")
  #     .then(&Deserialize)
  #     .map { |attrs| OpenStruct.new(attrs) }
  #     .unwrap(nil)
  #
  # While this example is contrived, it still illustrates some key advantages of
  # this programming paradigm:
  #
  # * chaining operations is as simple as repeatedly calling `then` or `map`,
  # * method objects don't have to be manually instantiated but can be
  #   constructed using the `&` operator,
  # * error handling is deferred until the result is unwrapped.
  #
  # Please see the section for `ShopifyCLI::Result`,
  # `ShopifyCLI::Result::Success`, and `ShopifyCLI::Result::Failure` for more
  # information on the API of result objects.
  #
  module MethodObject
    module AutoCreateResultObject
      def self.ruby2_keywords(*); end unless respond_to?(:ruby2_keywords, true)

      ##
      # invokes the original `call` implementation and wraps its return value
      # into a result object.
      #
      ruby2_keywords def call(*args, &block)
        Result.wrap { super(*args, &block) }.call
      end
    end

    module ClassMethods
      ##
      # creates a new instance and invokes `call`. Any positional argument
      # is forward to `call`. Keyword arguments are either forwarded to the
      # initializer or to `call`. If the keyword argument matches the name of
      # property, it is forwarded to the initializer, otherwise to call.
      #
      ruby2_keywords def call(*args, &block)
        # This is an extremely complicated case of delegation. The method wants
        # to delegate arguments, but to have control over which keyword
        # arguments are delegated. I'm not sure the forward and backward
        # compatibility of this unusual form of delegation has really been
        # explored or there's any good way to support it. So I have done
        # done something hacky here and I'm looking at the last argument and
        # modifying the package of arguments to be delegated in-place.
        if args.last.is_a?(Hash)
          kwargs = args.last

          initializer_kwargs = kwargs.slice(*properties.keys)
          instance = new(**initializer_kwargs)

          kwargs.reject! { |key| initializer_kwargs.key?(key) }
          args.pop if kwargs.empty?
          instance.call(*args, &block)
        else
          # Since the former is so complicated - let's have a fast path that
          # is much simpler.
          new.call(*args, &block)
        end
      end

      ##
      # returns a proc that invokes `call` with all arguments it receives when
      # called itself.
      #
      def to_proc
        method(:call).to_proc
      end
    end

    ##
    # is invoked when this mixin is included into a class. This results in
    #
    # * including `SmartProperties`,
    # * prepending the result wrapping mechanism, and
    # * adding the class methods `.call` and `.to_proc`.
    #
    def self.included(method_object_implementation)
      method_object_implementation.prepend(AutoCreateResultObject)
      method_object_implementation.include(SmartProperties)
      method_object_implementation.extend(ClassMethods)
    end

    ##
    # returns a proc that invokes `call` with all arguments it receives when
    # called itself.
    #
    def to_proc
      method(:call).to_proc
    end
  end
end
