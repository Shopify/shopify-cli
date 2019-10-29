# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class TestSuiteNotFoundError < StandardError
        def initialize(extension_point_type, script_name)
          super("There are no tests for extension point #{extension_point_type} script #{script_name}")
        end
      end
    end
  end
end
