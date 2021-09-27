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
          @sdks = ExtensionPointSDKs.new(config)
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
            @all ||= [
              new_sdk("assemblyscript"),
              new_sdk("rust"),
              new_sdk("typescript"),
            ].compact
          end

          def for(language)
            all.find { |ep| ep.language == language }
          end

          private

          def new_sdk(language)
            config = @config[language]
            return nil if config.nil?
            ExtensionPointSDK.new(language, config)
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
