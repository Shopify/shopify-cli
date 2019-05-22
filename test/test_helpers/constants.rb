module TestHelpers
  module Constants
    protected

    def teardown
      super
      reset_constants
    end

    def redefine_constant(mod, constant, new_value)
      @redefined_constants ||= []
      @redefined_constants << [mod, constant, mod.const_get(constant)]
      ignore_constant_redefined_warnings do
        mod.const_set(constant, new_value)
      end
    end

    def reset_constants
      return unless @redefined_constants

      @redefined_constants.each do |mod, constant, old_value|
        ignore_constant_redefined_warnings do
          mod.const_set(constant, old_value)
        end
      end

      @redefine_constants = nil
    end

    def ignore_constant_redefined_warnings
      warn_level = $VERBOSE
      $VERBOSE = nil
      yield
      $VERBOSE = warn_level
    end
  end
end
