# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ExtensionPoint
        attr_reader :type, :beta, :deprecated, :sdks, :domain

        def initialize(type, config)
          @type = type
          @beta = config["beta"] || false
          @deprecated = config["deprecated"] || false
          @domain = config["domain"] || nil
          @sdks = ExtensionPointSDKs.new(config["sdks"])
        end

        def beta?
          @beta
        end

        def deprecated?
          @deprecated
        end

        def dasherize_type
          @type.gsub("_", "-")
        end

        class ExtensionPointSDKs
          def initialize(config)
            @config = config
          end

          def all
            @all ||= @config.map do |language, sdk_config|
              ExtensionPointSDK.new(language, sdk_config)
            end
          end

          def for(language)
            all.find { |ep| ep.language == language }
          end
        end

        class ExtensionPointSDK
          attr_reader :language, :version, :beta, :package, :repo

          def initialize(language, config)
            @language = language
            @beta = config["beta"] || false
            @package = config["package"]
            @version = config["package-version"]
            @repo = config["repo"]
          end

          def beta?
            @beta
          end

          def versioned?
            @version
          end
        end
      end
    end
  end
end
