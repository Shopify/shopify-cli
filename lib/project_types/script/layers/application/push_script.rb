# frozen_string_literal: true

module Script
  module Layers
    module Application
      class PushScript
        class << self
          def call(ctx:, language:, extension_point_type:, script_name:, api_key:, force:)
            script = Infrastructure::ScriptRepository.new.get_script(language, extension_point_type, script_name)
            ProjectDependencies.install(ctx: ctx, language: language)
            BuildScript.call(ctx: ctx, script: script)
            push_script(ctx, script, api_key, force)
          end

          private

          def push_script(ctx, script, api_key, force)
            compiled_type = Infrastructure::TaskRunner.for(ctx, script.language).compiled_type
            Infrastructure::PushPackageRepository.new
              .get_push_package(script, compiled_type)
              .push(Infrastructure::ScriptService.new(ctx: ctx), api_key, force)
            ctx.puts(ctx.message('script.application.pushed'))
          end
        end
      end
    end
  end
end
