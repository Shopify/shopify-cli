module Script
  module Layers
    module Application
      class ProjectDependencies
        def self.bootstrap(ctx:, language:, extension_point:, script_name:)
          dep_manager = Infrastructure::DependencyManager.for(ctx, language, extension_point, script_name)
          dep_manager.bootstrap
        end

        def self.install(ctx:, language:)
          task_runner = Infrastructure::TaskRunner.for(ctx, language)

          CLI::UI::Frame.open(ctx.message('script.project_deps.checking_with_npm')) do
            begin
              if task_runner.dependencies_installed?
                ctx.puts(ctx.message('script.project_deps.none_required'))
              else
                UI::StrictSpinner.spin(ctx.message('script.project_deps.installing')) do |spinner|
                  task_runner.install_dependencies
                  spinner.update_title(ctx.message('script.project_deps.installed'))
                end
              end
              true
            rescue Infrastructure::Errors::DependencyInstallError => e
              CLI::UI::Frame.with_frame_color_override(:red) do
                ctx.puts("\n#{e.message}")
              end
              raise e
            end
          end
        end
      end
    end
  end
end
