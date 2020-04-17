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
          return ctx.puts("{{v}} Dependencies installed") if dep_manager.installed?

          unless CLI::UI::Frame.open("Installing dependencies with npm") do
            begin
              UI::StrictSpinner.spin('Dependencies installing') do |spinner|
                dep_manager.install
                spinner.update_title('Dependencies installed')
              end
              true
            rescue Infrastructure::DependencyInstallError => e
              CLI::UI::Frame.with_frame_color_override(:red) do
                ctx.puts("\n#{e.message}")
              end
              false
            end
          end
            raise Infrastructure::DependencyInstallError
          end
        end
      end
    end
  end
end
