
module ShopifyCLI
  ##
  # `TransformDataStructure` helps to standardize data structure access. It
  # traverses nested data structures and can convert
  #
  # * all strings used as keys to symbols,
  # * all strings used as keys from `CamelCase` to `snake_case` and
  # * associative array containers, e.g. from Hash to OpenStruct.
  #
  # Standardizing how a data structure is accessed greatly reduces the risk
  # of subtle bugs especially when dealing with API responses.
  #
  #    TransformDataStructure.new(
  #      symbolize_keys: true,
  #      underscore_keys: true,
  #      associative_array_container: OpenStruct
  #    ).call([{"SomeKey" => "value"}]).tap do |result|
  #      result.value # => [#<OpenStruct: some_key: "value">]
  #    end
  #
  # Since `TransformDataStructure` is a method object, it can easily be chained:
  #
  #    require 'open-uri'
  #    ShopifyCLI::Result
  #      .call { open("https://jsonplaceholder.typicode.com/todos/1") }
  #      .map(&TransformDataStructure.new(symbolize_keys: true, underscore_keys: true))
  #      .value # => { id: 1, user_id: 1, ... }
  #
  class TransformDataStructure
    include ShopifyCLI::MethodObject

    class << self
      private

      def valid_associative_array_container(klass)
        klass.respond_to?(:new) && klass.method_defined?(:[]=)
      end
    end

    property! :underscore_keys, accepts: [true, false], default: false, reader: :underscore_keys?
    property! :symbolize_keys, accepts: [true, false], default: false, reader: :symbolize_keys?
    property! :shallow, accepts: [true, false], default: false, reader: :shallow?
    property! :associative_array_container,
      accepts: ->(c) { c.respond_to?(:new) && c.method_defined?(:[]=) },
      default: -> { Hash }

    def call(object)
      case object
      when Array
        shallow? ? object.dup : object.map(&self).map(&:value)
      when Hash
        object.each.with_object(associative_array_container.new) do |(key, value), result|
          result[transform_key(key)] = shallow? ? value : call(value).value
        end
      else
        ShopifyCLI::Result.success(object)
      end
    end

    private

    def transform_key(key)
      key
        .yield_self(&method(:underscore_key))
        .yield_self(&method(:symbolize_key))
    end

    def underscore_key(key)
      return key unless underscore_keys? && key.respond_to?(:to_str)

      key.to_str.dup.tap do |k|
        k.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
        k.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        k.tr!("-", "_")
        k.gsub!(/\s/, "_")
        k.gsub!(/__+/, "_")
        k.downcase!
      end
    end

    def symbolize_key(key)
      return key unless symbolize_keys? && key.respond_to?(:to_sym)
      key.to_sym
    end
  end
end
