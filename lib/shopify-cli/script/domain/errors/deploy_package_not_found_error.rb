# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class DeployPackageNotFoundError < StandardError
        def initialize(extension_point_type, script_name)
          super("Script with extension point #{extension_point_type} script #{script_name} hasn't been built")
        end
      end
    end
  end
end
