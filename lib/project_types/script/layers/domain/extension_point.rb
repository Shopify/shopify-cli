# frozen_string_literal: true

module Script
  module Layers
    module Domain
      class ExtensionPoint
        attr_reader :type, :beta, :deprecated, :libraries, :domain

        def initialize(type, config)
          @type = type
          @beta = config["beta"] || false
          @deprecated = config["deprecated"] || false
          @domain = config["domain"] || nil
          @libraries = ExtensionPointLibraries.new(config["libraries"])
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

        class ExtensionPointLibraries
          def initialize(config)
            @config = config
          end

          def all
            @all ||= @config.map do |language, libray_config|
              ExtensionPointLibrary.new(language, libray_config)
            end
          end

          def for(language)
            all.find { |ep| ep.language == language }
          end
        end

        class ExtensionPointLibrary
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
