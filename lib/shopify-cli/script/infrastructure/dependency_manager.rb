# frozen_string_literal: true
require 'fileutils'

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class NoopDependencyManager
        def initialize(_ctx, script_name, language)
          @language = language
          @script_name = script_name
        end

        def installed?
        end

        def install
        end
      end

      class DependencyManager
        DEP_MANAGER = {
          "ts" => Infrastructure::TypeScriptDependencyManager,
          "js" => NoopDependencyManager,
          "json" => NoopDependencyManager,
        }

        def self.for(ctx, script_name, language)
          raise(Infrastructure::DependencyError, language) unless DEP_MANAGER[language]
          DEP_MANAGER[language].new(ctx, script_name, language)
        end
      end
    end
  end
end
