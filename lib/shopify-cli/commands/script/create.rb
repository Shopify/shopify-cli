require 'shopify_cli'

module ShopifyCli
  module Commands
    class Script
      class Create < ShopifyCli::SubCommand
        CMD_DESCRIPTION = "Create a new script for an extension point from the default template"
        CMD_USAGE = "create <Extension Point> <Script Name>"
        CREATED_NEW_SCRIPT_MSG = "{{v}}{{green: %{script_filename}}} was successfully created in %{folder}/"
        INVALID_EXTENSION_POINT = "Invalid extension point %{extension_point}"

        def call(args, _name)
          extension_point = args.shift
          return @ctx.puts(self.class.help) unless extension_point

          name = args.shift
          return @ctx.puts(self.class.help) unless name

          language = if args.include?("--language")
            index = args.index("--language")
            args[index + 1]
          else
            "ts"
          end

          return @ctx.puts(self.class.help) unless ScriptModule::LANGUAGES.include?(language)

          script = bootstrap(@ctx, language, extension_point, name)

          dep_manager = ScriptModule::Infrastructure::DependencyManager.for(name, language)

          ScriptModule::Infrastructure::ScriptRepository.new.with_script_context(name) do
            unless dep_manager.installed?
              CLI::UI::Frame.open('Installing Dependencies in {{green:package.json}}...') do
                CLI::UI::Spinner.spin('Installing') do |spinner|
                  dep_manager.install
                  spinner.update_title('Installed')
                end
              end
            end
          end

          @ctx.puts(format(CREATED_NEW_SCRIPT_MSG, script_filename: script.filename, folder: script.name))
        end

        def self.help
          <<~HELP
            #{CMD_DESCRIPTION}
              Usage: {{command:#{ShopifyCli::TOOL_NAME} #{CMD_USAGE}}}
          HELP
        end

        private

        def bootstrap(ctx, language, extension_point, name)
          CLI::UI::Frame.open("Cloning into #{name}...") do
            CLI::UI::Progress.progress do |bar|
              script = ScriptModule::Application::Bootstrap.call(ctx, language, extension_point, name)
              bar.tick(set_percent: 1.0)
              script
            end
          end
        rescue ScriptModule::Domain::InvalidExtensionPointError
          @ctx.puts(format(INVALID_EXTENSION_POINT, extension_point: extension_point))
        end
      end
    end
  end
end
