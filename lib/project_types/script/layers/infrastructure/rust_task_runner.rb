# frozen_string_literal: true
module Script
  module Layers
    module Infrastructure
      class RustTaskRunner
        attr_reader :ctx, :script_name

        BUILD_TARGET = "wasm32-unknown-unknown"
        METADATA_FILE = "build/metadata.json"

        def initialize(ctx, script_name)
          @ctx = ctx
          @script_name = script_name
        end

        def dependencies_installed?
          true
        end

        def install_dependencies
        end

        def build
          compile
          bytecode
        end

        def compiled_type
          "wasm"
        end

        def metadata
          unless @ctx.file_exist?(METADATA_FILE)
            msg = @ctx.message("script.error.metadata_not_found_cause", METADATA_FILE)
            raise Domain::Errors::MetadataNotFoundError, msg
          end

          raw_contents = File.read(METADATA_FILE)
          Domain::Metadata.create_from_json(@ctx, raw_contents)
        end

        private

        def compile
          out, status = ctx.capture2e("cargo build --target=#{BUILD_TARGET} --release")
          raise Domain::Errors::ServiceFailureError, out unless status.success?
        end

        def bytecode
          binary_name = "#{script_name}.wasm"
          binary_path = "target/#{BUILD_TARGET}/release/#{binary_name}"
          raise Errors::WebAssemblyBinaryNotFoundError unless ctx.file_exist?(binary_path)

          ctx.binread(binary_path)
        end
      end
    end
  end
end
