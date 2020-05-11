# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class NoopDependencyManager
        def initialize(_ctx, language, _extension_point, script_name)
          @language = language
          @script_name = script_name
        end

        def bootstrap
        end

        def installed?
        end

        def install
        end
      end

      class DependencyManager
        DEP_MANAGER = {
          "ts" => AssemblyScriptDependencyManager,
          "js" => NoopDependencyManager,
          "json" => NoopDependencyManager,
        }

        def self.for(ctx, language, extension_point, script_name)
          raise Errors::DependencyError, language unless DEP_MANAGER[language]
          DEP_MANAGER[language].new(ctx, language, extension_point, script_name)
        end
      end
    end
  end
end
