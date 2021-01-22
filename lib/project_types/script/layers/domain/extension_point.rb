# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ExtensionPoint
        attr_reader :type, :deprecated, :sdks

        def initialize(type, config)
          @type = type
          @deprecated = config["deprecated"] || false
          @sdks = ExtensionPointSDKs.new(config)
        end

        def deprecated?
          @deprecated
        end
      end

      class ExtensionPointSDKs
        def initialize(config)
          @config = config
        end

        def all
          [assemblyscript, rust].compact
        end

        def assemblyscript
          @assemblyscript ||= new_sdk(ExtensionPointAssemblyScriptSDK, @config['assemblyscript'])
        end

        def rust
          @rust ||= new_sdk(ExtensionPointRustSDK, @config['rust'])
        end

        private

        def new_sdk(klass, config)
          return nil if config.nil?
          klass.new(config)
        end
      end

      class ExtensionPointSDK
        attr_reader :beta, :package

        def initialize(config)
          @beta = config["beta"]
          @package = config["package"]
        end

        def beta?
          @beta
        end

        def language
          raise NotImplementedError
        end
      end

      class ExtensionPointAssemblyScriptSDK < ExtensionPointSDK
        attr_reader :sdk_version, :toolchain_version

        def initialize(config)
          super
          @sdk_version = config["sdk-version"]
          @toolchain_version = config["toolchain-version"]
        end

        def language
          "assemblyscript"
        end
      end

      class ExtensionPointRustSDK < ExtensionPointSDK
        def language
          "rust"
        end
      end
    end
  end
end
