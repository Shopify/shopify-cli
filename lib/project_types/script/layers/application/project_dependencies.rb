module Script
  module Layers
    module Application
      class ProjectDependencies
        def self.bootstrap(ctx:, language:, extension_point:, script_name:)
          dep_manager = Infrastructure::DependencyManager.for(ctx, language, extension_point, script_name)
          dep_manager.bootstrap
        end

        def self.install(ctx:, language:, extension_point:, script_name:)
          dep_manager = Infrastructure::DependencyManager.for(ctx, language, extension_point, script_name)
          return ctx.puts(ctx.message('script.project_deps.deps_are_installed')) if dep_manager.installed?

          unless CLI::UI::Frame.open(ctx.message('script.project_deps.installing_with_npm')) do
            begin
              UI::StrictSpinner.spin(ctx.message('script.project_deps.installing')) do |spinner|
                dep_manager.install
                spinner.update_title(ctx.message('script.project_deps.installed'))
              end
              true
            rescue Infrastructure::Errors::DependencyInstallError => e
              CLI::UI::Frame.with_frame_color_override(:red) do
                ctx.puts("\n#{e.message}")
              end
              false
            end
          end
            raise Infrastructure::Errors::DependencyInstallError
          end
        end
      end
    end
  end
end
