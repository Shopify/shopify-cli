# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class DeployPackageRepository < Repository
        def create_deploy_package(script, bytecode)
          base = "#{src_base(script.extension_point.type, script.name)}/build"
          FileUtils.mkdir_p(base)
          File.write("#{base}/#{script.name}.wasm", bytecode)

          id = wasm_blob_file_path(script.extension_point.type, script.name)
          Domain::DeployPackage.new(id, script, bytecode)
        end

        def get_deploy_package(language, extension_point_type, script_name)
          script = ScriptRepository.new.get_script(language, extension_point_type, script_name)

          id = wasm_blob_file_path(extension_point_type, script_name)
          raise Domain::WasmNotFoundError.new(extension_point_type, script_name) unless File.exist?(id)

          Domain::DeployPackage.new(id, script, File.read(id))
        end

        private

        def src_base(extension_point_type, script_name)
          "#{SOURCE_PATH}/#{extension_point_type}/#{script_name}"
        end

        def wasm_blob_file_path(extension_point_type, script_name)
          "#{src_base(extension_point_type, script_name)}/build/#{script_name}.wasm"
        end
      end
    end
  end
end
