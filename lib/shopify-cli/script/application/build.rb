# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class Build
        def self.call(language, extension_point_type, script_name)
          script_repo = Infrastructure::ScriptRepository.new
          script = script_repo.get_script(language, extension_point_type, script_name)

          script_content = script_repo.with_script_context(script) do
            Infrastructure::ScriptBuilder.for(script).build
          end

          Infrastructure::DeployPackageRepository.new
            .create_deploy_package(script, script_content)
        end
      end
    end
  end
end
