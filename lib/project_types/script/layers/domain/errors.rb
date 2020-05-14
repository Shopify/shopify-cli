# frozen_string_literal: true

module Script
  module Layers
    module Domain
      module Errors
        class DeployPackageNotFoundError < ScriptProjectError; end
        class InvalidExtensionPointError < ScriptProjectError
          attr_reader :type
          def initialize(type)
            @type = type
          end
        end
        class ScriptNotFoundError < ScriptProjectError
          attr_reader :script_name, :extension_point_type
          def initialize(extension_point_type, script_name)
            @script_name = script_name
            @extension_point_type = extension_point_type
          end
        end
        class ServiceFailureError < ScriptProjectError; end
        class TestSuiteNotFoundError < ScriptProjectError; end
      end
    end
  end
end
