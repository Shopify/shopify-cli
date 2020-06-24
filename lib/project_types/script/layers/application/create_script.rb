# frozen_string_literal: true

require "shopify_cli"

module Script
  module Layers
    module Application
      class CreateScript
        class << self
          def call(ctx:, language:, script_name:, extension_point_type:)
            extension_point = ExtensionPoints.get(type: extension_point_type)
            project = create_project(ctx, script_name, extension_point)
            install_dependencies(ctx, language, script_name, extension_point, project)
            script = create_definition(ctx, language, extension_point, script_name)
            ShopifyCli::Core::Finalize.request_cd(script_name)
            script
          end

          private

          def create_project(ctx, script_name, extension_point)
            ScriptProject.create(script_name)
            ctx.root = File.join(ctx.root, script_name)
            ScriptProject.write(
              ctx,
              project_type: :script,
              organization_id: nil, # TODO: can you provide this at creation
              extension_point_type: extension_point.type,
              script_name: script_name
            )
            ScriptProject.current
          end

          def install_dependencies(ctx, language, script_name, extension_point, project)
            task_runner = Infrastructure::TaskRunner.for(ctx, language, script_name, project.source_file)
            ProjectDependencies
              .bootstrap(ctx: ctx, language: language, extension_point: extension_point, script_name: script_name)
            ProjectDependencies
              .install(ctx: ctx, task_runner: task_runner)
          end

          def create_definition(ctx, language, extension_point, script_name)
            script = nil
            UI::StrictSpinner.spin(ctx.message('script.create.creating')) do |spinner|
              script = Infrastructure::ScriptRepository.new.create_script(language, extension_point, script_name)
              Infrastructure::TestSuiteRepository.new.create_test_suite(script)
              spinner.update_title(ctx.message('script.create.created'))
            end
            script
          end
        end
      end
    end
  end
end
