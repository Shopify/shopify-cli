# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class WasmTaskRunner < TaskRunner
          BYTECODE_FILE = "build/index.wasm"

          def dependencies_installed?
            true
          end

          def install_dependencies; end

          def library_version(_library_name)
            nil
          end

          def metadata_file_location
            "metadata.json"
          end

          def build
            # raise Errors::WebAssemblyBinaryNotFoundError
            raise Errors::WebAssemblyBinaryNotFoundError unless ctx.file_exist?(BYTECODE_FILE)
            ctx.binread(BYTECODE_FILE)
          end
        end
      end
    end
  end
end
