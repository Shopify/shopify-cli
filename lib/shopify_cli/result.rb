module ShopifyCLI
  ##
  # This module defines two containers for wrapping the result of an action. One
  # for signifying the successful execution of an action and one for signifying
  # a failure. Both containers implement the same API, which has been designed
  # to simplify transforming a result through a series of steps and centralize
  # the error handling in one place. The implementation is heavily inspired by a
  # concept known as result monads in other languages. Consider the following
  # example that uses lambda expressions as stand-ins for more complex method
  # objects:
  #
  #   require 'open-uri'
  #   Todo = Struct.new(:title, :completed)
  #
  #   fetch_data = ->(url) { open(url) }
  #   parse_data = ->(json) { JSON.parse(json) }
  #   build_todo = ->(attrs) do
  #     Todo.new(attrs.fetch(:title), attrs.fetch(:completed))
  #   end
  #
  #   Result.wrap(&fetch_data)
  #     .call("https://jsonplaceholder.typicode.com/todos/1")
  #     .then(&parse_data)
  #     .then(&build_todo)
  #     .map(&:title)
  #     .unwrap(nil) # => String | nil
  #
  # If everything goes well, this code returns the title of the to do that is
  # being fetched from `https://jsonplaceholder.typicode.com/todos/1`. However,
  # there are several possible failure scenarios:
  #
  # * fetching the data could fail due to a network error,
  # * the data returned from the server might not be valid JSON, or
  # * the data is valid but does not have the right shape.
  #
  # If any of these scenarios arises, all subsequent `then` and `map` blocks are
  # skipped until the result is either unwrapped or we manually recover from the
  # failure by specifying a `rescue` clause:
  #
  #   Result.wrap { raise "Boom!" }
  #     .rescue { |e| e.message.upcase }
  #     .unwrap(nil) # => "BOOM!"
  #
  # In the event of a failure that hasn't been rescued from,
  # `unwrap` returns the fallback value specified by the caller:
  #
  #   Result.wrap { raise "Boom!" }.unwrap(nil) # => nil
  #   Result.wrap { raise "Boom!" }.unwrap { |e| e.message } # => "Boom!"
  #
  module Result
    class Error < RuntimeError; end
    class UnexpectedSuccess < Error; end
    class UnexpectedFailure < Error; end

    ##
    # Implements a container for wrapping a success value. The main purpose of
    # the container is to support further transformations of the result and
    # centralize error handling should any of the subsequent transformations
    # fail:
    #
    #   result = Result
    #     .new("{}")
    #     .then { |json| JSON.parse(json) }
    #     .tap do |result|
    #       result.success? # => true
    #       result.value # => {}
    #     .then { |data| data.fetch(:firstname) }
    #     .tap do |result|
    #       result.failure? # => true
    #       result.error # => KeyError
    #     end
    #
    # `Success` implements two transformation functions: `then` and `map`. The
    # former makes no assumption regarding the return value of the
    # transformation. The latter on the other hand expects the transformation to
    # be successful. If this assumption is violated, program execution is
    # interrupted and an error is raised. As the purpose of result objects is to
    # guard against exactly that. This is generally a flaw and requires the code
    # to either be hardened or to substitute the call to `map` with a call to
    # `then`. `map` should only be used for transformations that cannot fail and
    # when the caller wants to state exactly that fact.
    #
    class Success
      attr_reader :value

      ##
      # initializes a new `Success` from an arbitrary value.
      def initialize(value)
        @value = value
      end

      ##
      # always returns true to indicate that this result represents a success.
      #
      def success?
        true
      end

      ##
      # always returns false to indicate that this result represents a success.
      #
      def failure?
        false
      end

      ##
      # raises an `UnexpectedSuccess` as a `Success` does not carry an error
      # value.
      #
      def error
        raise UnexpectedSuccess
      end

      ##
      # returns a new `Success` wrapping the result of the given block. The
      # block is called with the current value. If the block raises an exception
      # or returns a `Failure`, an exception is raised. `map` assumes any
      # transformation to succeed. Transformations that are expected to fail under
      # certain conditions should only be transformed using `then`:
      #
      #   Success
      #     .new(nil)
      #     .map { |n| n + 1 } # => raises NoMethodError
      #
      # Therefore, map should only be used here if the previous success value is
      # guaranteed to be a number or if the block handles nil cases properly:
      #
      #   Success
      #     .new(nil)
      #     .map { |n| (n || 0) + 1 }
      #     .value # => 1
      #
      def map(&block)
        self.then(&block).tap do |result|
          return result if result.success?

          result.unwrap { |error| error }.tap do |error|
            case error
            when Exception
              raise error
            else
              raise UnexpectedFailure, error
            end
          end
        end
      end

      ##
      # returns a new result by wrapping the return value of the block. The
      # block is invoked with the current success value. The result can either
      # be a `Success` or a `Failure`. The former is the default. The latter
      # occurs when executing the block either
      #
      # - raised an exception,
      # - returned an instance of a subclass of `Exception`, or
      # - returned a `Failure`.
      #
      # The example below illustrates this behavior:
      #
      #   result = Success
      #     .new(1)
      #     .then { |n| n + 1 }
      #     .tap do |result|
      #       result.success? # => true
      #       result.value # => 2
      #     end
      #
      #   result.then { |n| n / 0 }.error # => ZeroDivisionError
      #   result.then { RuntimeError.new }.error # => RuntimeError
      #   result.then { Failure.new("Boom!") }.error # => "Boom!"
      #
      def then(&block)
        Result.wrap(&block).call(@value)
      end

      ##
      # is a no-op and simply returns itself. Only a `Failure` can be
      # transformed using `rescue`.
      #
      def rescue
        self
      end

      ##
      # returns the value this success represents
      #
      def unwrap!
        value
      end

      ##
      # returns the success value and ignores the fallback value that was either
      # provided as a method argument or by passing a block. However, the caller
      # is still required to specify a fallback value to ensure that in the
      # event of a `Failure` program execution can continue in a controlled
      # manner:
      #
      #    Success.new(1).unwrap(0) => 1
      #
      def unwrap(*args, &block)
        raise ArgumentError, "expected either a fallback value or a block" unless (args.length == 1) ^ block
        @value
      end
    end

    ##
    # Implements a container for wrapping an error value. In many cases, the
    # error value is going to be an exception but other values are fully
    # supported:
    #
    #   Failure
    #     .new(RuntimeError.new("Something went wrong"))
    #     .error # => RuntimeError.new
    #
    #   Failure
    #     .new("Something went wrong")
    #     .error # => "Something went wrong"
    #
    # `Failure` does not support transformations with `then` and `map`. When any
    # of these two methods is invoked on a `Failure`, the `Failure` itself is
    # returned unless it is rescued from or unwrapped. This enables the caller to
    # build optimistic transformation chains and defer error handling:
    #
    #   Failure
    #     .new(nil)
    #     .then { |json| JSON.parse(json) }                      # Ignored
    #     .then(&:with_indifferent_access)                       # Ignored
    #     .then { |data| data.values_at(:firstname, :lastname) } # Ignored
    #     .unwrap(Person.new("John", "Doe"))                     # => Person
    #
    # Alternatively, we could rescue from the error and then proceed with the
    # remaining transformations:
    #
    #   Person = Struct.new(:firstname, :lastname)
    #   Failure
    #     .new(nil)
    #     .then { |json| JSON.parse(json) }                      # Ignored
    #     .then(&:with_indifferent_access)                       # Ignored
    #     .rescue { {firstname: "John", lastname: "Doe" }}
    #     .then { |data| data.values_at(:firstname, :lastname) } # Executed
    #     .then { |members| Person.new(*members) }               # Executed
    #     .unwrap(nil)                                           # => Person
    #
    class Failure
      attr_reader :error

      ##
      # initializes a new `Failure` from an arbitrary value. In many cases, this
      # value is going to be an instance of a subclass of `Exception` but any
      # type is supported.
      #
      def initialize(error)
        @error = error
      end

      ##
      # always returns `false` to indicate that this result represents a failure.
      #
      def success?
        false
      end

      ##
      # Always returns `true` to indicate that this result represents a failure.
      #
      def failure?
        true
      end

      ##
      # raises an `ShopifyCLI::Result::UnexpectedError` as a
      # `ShopifyCLI::Result::Failure` does not carry a success value.
      #
      def value
        raise UnexpectedFailure
      end

      ##
      # is a no-op and simply returns itself. This is essential to skip
      # transformation steps in a chain once an error has occurred.
      #
      def map
        self
      end

      ##
      # is a no-op and simply returns itself. This is essential to skip
      # transformation steps in a chain once an error has occurred.
      #
      def then
        self
      end

      ##
      # can be used to recover from a failure or produce a new failure with a
      # different error.
      #
      #   Failure
      #     .new("Something went wrong")
      #     .rescue { |msg| [msg, "but we fixed it!"].join(" "") }
      #     .tap do |result|
      #        result.success? # => true
      #        result.value # => "Something went wrong but we fixed it!"
      #     end
      #
      # `rescue` is opinionated when it comes to the return value of the block.
      # If the return value is an `Exception` – either one that was raised or an
      # instance of a subclass of `Exception` – a `Failure` is returned. Any
      # other value results in a `Success` unless the value has been explicitly
      # wrapped in a `Failure`:
      #
      #   Failure
      #     .new(RuntimeError.new)
      #     .rescue { "All good! "}
      #     .success? # => true
      #
      #   Failure
      #     .new(RuntimeError.new)
      #     .rescue { Failure.new("Still broken!") }
      #     .success? # => false
      #
      def rescue(&block)
        Result.wrap(&block).call(@error)
      end

      ##
      # returns the fallback value specified by the caller. The fallback value
      # can be provided as a method argument or as a block. If a block is given,
      # it receives the error as its first and only argument:
      #
      #   failure = Failure.new(RuntimeError.new("Something went wrong!"))
      #
      #   failure.unwrap(nil) # => nil
      #   failure.unwrap { |e| e.message } # => "Something went wrong!"
      #
      # #### Parameters
      #
      # * `*args` should be an `Array` with zero or one element
      # * `&block`  should be a Proc that takes zero or one argument
      #
      # #### Raises
      #
      # * `ArgumentError` if both a fallback argument and a block is provided
      #
      def unwrap(*args, &block)
        raise ArgumentError, "expected either a fallback value or a block" unless (args.length == 1) ^ block
        block ? block.call(@error) : args.pop
      end

      ##
      # raises the error this failure represents
      #
      def unwrap!
        raise error
      end
    end

    ##
    # wraps the given value into a `ShopifyCLI::Result::Success` container
    #
    # #### Parameters
    #
    # * `value` a value of arbitrary type
    #
    def self.success(value)
      Result::Success.new(value)
    end

    ##
    # wraps the given value into a `ShopifyCLI::Result::Failure` container
    #
    # #### Parameters
    #
    # * `error` a value of arbitrary type
    #
    def self.failure(error)
      Result::Failure.new(error)
    end

    class << self
      ##
      # takes either a value or a block and chooses the appropriate result
      # container based on the type of the value or the type of the block's return
      # value. If the type is an exception, it is wrapped in a
      # `ShopifyCli::Result::Failure` and otherwise in a
      # `ShopifyCli::Result::Success`. If a block was provided instead of value, a
      # `Proc` is returned and the result wrapping doesn't occur until the block
      # is invoked.
      #
      # #### Parameters
      #
      # * `*args` should be an `Array` with zero or one element
      # * `&block` should be a `Proc` that takes zero or one argument
      #
      # #### Returns
      #
      # Returns either a `Result::Success`, `Result::Failure` or a `Proc` that
      # produces one of the former when invoked.
      #
      # #### Examples
      #
      #   Result.wrap(1) # => ShopifyCli::Result::Success
      #   Result.wrap(RuntimeError.new) # => ShopifyCli::Result::Failure
      #
      #   Result.wrap { 1 } # => Proc
      #   Result.wrap { 1 }.call # => ShopifyCli::Result::Success
      #   Result.wrap { raise }.call # => ShopifyCli::Result::Failure
      #
      #   Result.wrap { |s| s.upcase }.call("hello").tap do |result|
      #     result # => Result::Success
      #     result.value # => "HELLO"
      #   end
      #
      ruby2_keywords def wrap(*values, &block)
        raise ArgumentError, "expected either a value or a block" unless (values.length == 1) ^ block

        if values.length == 1
          values.pop.yield_self do |value|
            case value
            when Result::Success, Result::Failure
              value
            when NilClass, Exception
              Result.failure(value)
            else
              Result.success(value)
            end
          end
        else
          ->(*args) do
            begin
              wrap(block.call(*args))
            rescue Exception => error # rubocop:disable Lint/RescueException
              wrap(error)
            end
          end.ruby2_keywords
        end
      end

      ##
      # Wraps the given block and invokes it with the passed arguments.
      #
      ruby2_keywords def call(*args, &block)
        raise ArgumentError, "expected a block" unless block
        wrap(&block).call(*args)
      end
    end
  end
end
