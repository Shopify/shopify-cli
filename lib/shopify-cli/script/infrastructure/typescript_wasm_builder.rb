# frozen_string_literal: true

require "tmpdir"

ASM_SCRIPT_SOURCE = "git://github.com/AssemblyScript/assemblyscript#3b227d47b1c546ddd0ae19fbd49bdae9ad5c1c99"
INSTALL_ASSEMBLY_SCRIPT = "npm i -D #{ASM_SCRIPT_SOURCE} > /dev/null 2>&1"
BUILD_FILE = "build.wasm"
ASSEMBLY_FILE = "assembly.ts"
TSCONFIG_FILE = "tsconfig.json"
TSCONFIG = "{
  \"extends\": \"./node_modules/assemblyscript/std/assembly.json\",
}"
ASSEMBLY_INDEX = "export function shopify_runtime_allocate(size: u32): ArrayBuffer { return new ArrayBuffer(size); }
import { run } from \"./%{entrypoint}\"
export { run };"
ASM_SCRIPT_OPTIMIZED = "npx asc assembly.ts -b build/%{script}.wasm --sourceMap --validate \
--optimize --use abort= --runtime none"

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class TypeScriptWasmBuilder
        attr_reader :script

        def initialize(script)
          @script = script
        end

        def build
          prepare
          install_builder_framework
          compile
          bytecode
        end

        def compiled_type
          "wasm"
        end

        private

        def prepare
          File.write(ASSEMBLY_FILE, format(ASSEMBLY_INDEX, entrypoint: script.name))
          File.write(TSCONFIG_FILE, TSCONFIG)
        end

        def install_builder_framework
          system(INSTALL_ASSEMBLY_SCRIPT)
        end

        def compile
          build_success = system(format(ASM_SCRIPT_OPTIMIZED, script: script.name))
          raise Domain::ServiceFailureError unless build_success
        end

        def bytecode
          File.read("build/#{script.name}.wasm")
        end
      end
    end
  end
end
