module Script
  module Layers
    module Application
      class ProjectDependencies
        def self.install(ctx:, task_runner:)
          CLI::UI::Frame.open(ctx.message("script.project_deps.checking")) do
            if task_runner.dependencies_installed?
              ctx.puts(ctx.message("script.project_deps.none_required"))
            else
              UI::StrictSpinner.spin(ctx.message("script.project_deps.installing")) do |spinner|
                task_runner.install_dependencies
                spinner.update_title(ctx.message("script.project_deps.installed"))
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
