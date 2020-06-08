# frozen_string_literal: true

module Script
  module Layers
    module Application
      class DeployScript
        class << self
          def call(ctx:, language:, extension_point_type:, script_name:, api_key:, force:)
            extension_point = ExtensionPoints.get(type: extension_point_type)
            script = Infrastructure::ScriptRepository.new.get_script(language, extension_point_type, script_name)
            ProjectDependencies
              .install(ctx: ctx, language: language, extension_point: extension_point, script_name: script_name)
            BuildScript.call(ctx: ctx, script: script)
            deploy_script(ctx, script, api_key, force)
          end

          private

          def deploy_script(ctx, script, api_key, force)
            compiled_type = Infrastructure::ScriptBuilder.for(script).compiled_type
            Infrastructure::DeployPackageRepository.new
              .get_deploy_package(script, compiled_type)
              .deploy(Infrastructure::ScriptService.new(ctx: ctx), api_key, force)
            ctx.puts(ctx.message('script.application.deployed'))
          end
        end
      end
    end
  end
end
