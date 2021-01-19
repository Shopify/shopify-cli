module Extension
  module MethodObject
    module ClassMethods
      def to_proc
        ->(*args, **kwargs) { call(*args, **kwargs) }
      end

      def call(*args, **kwargs)
        property_names = properties.keys
        property_kwargs = kwargs.slice(*property_names)
        remaining_kwargs = kwargs.slice(*(kwargs.keys - property_names))
        args = remaining_kwargs.any? ? args.push(remaining_kwargs) : args
        
        new(**property_kwargs).call(*args)
      end
    end

    module AutoCreateResultObject
      def call(*)
        value = super
        value.is_a?(Result::Base) ? value : Result.ok(value)
      rescue => e
        Result.error(e)
      end
    end

    def self.included(method_object_implementation)
      method_object_implementation.include(SmartProperties)
      method_object_implementation.prepend(AutoCreateResultObject)
      method_object_implementation.extend(ClassMethods)
      super(method_object_implementation)
    end

    def call(*)
      raise NotImplementedError
    end
    
    def to_proc
      ->(*args) { call(*args) }
    end

    protected

    def transform(value, &block)
      case value
      when Array
        value.map(&block)
      else
        value.yield_self(&block)
      end
    end
  end
end
