# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class ScriptNotFoundError < StandardError
        def initialize(extension_point_type, script_name)
          super("script: #{script_name} for extension point: #{extension_point_type} not found")
          @script_name = script_name
          @extension_point_type = extension_point_type
        end
        attr_reader :script_name, :extension_point_type
      end
    end
  end
end
