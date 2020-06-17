# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class AssemblyScriptWasmBuilder
        BYTECODE_FILE = "%{name}.wasm"
        SCRIPT_SDK_BUILD = "npx --no-install shopify-scripts-build --src=../%{source} --binary=#{BYTECODE_FILE} "\
                           "-- --lib=../node_modules --validate --optimize"

        attr_reader :script

        def initialize(script)
          @script = script
        end

        def build
          compile
          bytecode
        end

        def compiled_type
          "wasm"
        end

        private

        def compile
          out, status = CLI::Kit::System.capture2e(format(SCRIPT_SDK_BUILD, source: script.id, name: script.name))
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        def bytecode
          File.read(format(BYTECODE_FILE, name: script.name))
        end
      end
    end
  end
end
