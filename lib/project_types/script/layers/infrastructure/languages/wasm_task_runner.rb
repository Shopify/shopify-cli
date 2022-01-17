# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class WasmTaskRunner
          BYTECODE_FILE = "script.wasm"
          attr_reader :ctx, :script_name

          def initialize(ctx, script_name)
            @ctx = ctx
            @script_name = script_name
          end

          def dependencies_installed?
            true
          end

          def library_version(_library_name)
            nil
          end

          def compiled_type
            "wasm"
          end

          def metadata_file_location
            "metadata.json"
          end

          def build
            raise Errors::WebAssemblyBinaryNotFoundError unless ctx.file_exist?(BYTECODE_FILE)
            ctx.binread(BYTECODE_FILE)
          end
        end
      end
    end
  end
end
