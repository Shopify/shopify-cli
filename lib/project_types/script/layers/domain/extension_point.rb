# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ExtensionPoint
        attr_reader :type, :sdks

        def initialize(type, config)
          @type = type
          @sdks = {
            ts: ExtensionPointAssemblyScriptSDK.new(config["assemblyscript"]),
          }
        end
      end

      class ExtensionPointAssemblyScriptSDK
        attr_reader :package, :version, :sdk_version

        def initialize(config)
          @package = config["package"]
          @version = config["version"]
          @sdk_version = config["sdk-version"]
        end
      end
    end
  end
end
