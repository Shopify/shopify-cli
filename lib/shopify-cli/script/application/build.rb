# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Build
        def self.call(language, extension_point_type, script_name)
          script_repo = Infrastructure::ScriptRepository.new
          script = script_repo.get_script(language, extension_point_type, script_name)

          byte_code = script_repo.with_script_context(script) do
            Infrastructure::TypeScriptWasmBuilder.new(script).build
          end

          Infrastructure::DeployPackageRepository.new
            .create_deploy_package(script, byte_code)
        end
      end
    end
  end
end
