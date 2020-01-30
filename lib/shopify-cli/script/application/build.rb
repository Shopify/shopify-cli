# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Build
        def self.call(language, extension_point_type, script_name)
          script_repo = Infrastructure::ScriptRepository.new
          script = script_repo.get_script(language, extension_point_type, script_name)

          script_builder = Infrastructure::ScriptBuilder.for(script)
          compiled_type = script_builder.compiled_type
          script_content, schema = script_repo.with_script_build_context(script) do
            script_builder.build
          end

          Infrastructure::DeployPackageRepository.new
            .create_deploy_package(script, script_content, schema, compiled_type)
        end
      end
    end
  end
end
