# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class NoopBuilder
        def initialize(script)
          @script = script
        end

        def build
          File.read(@script.filename)
        end

        def compiled_type
          @script.language
        end
      end

      class ScriptBuilder
        COMPILERS = {
          "ts" => Infrastructure::TypeScriptWasmBuilder,
          "js" => Infrastructure::NoopBuilder,
          "json" => Infrastructure::NoopBuilder,
        }

        def self.for(script)
          raise BuilderNotFoundError unless COMPILERS[script.language]

          COMPILERS[script.language].new(script)
        end
      end
    end
  end
end
