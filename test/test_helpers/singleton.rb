# frozen_string_literal: true

module TestHelpers
  module Singleton
    class << self
      def reset_singleton!(instance)
        instance.instance_variables.each do |var_name|
          instance.instance_variable_set(var_name, nil)
        end
      end
    end
  end
end
