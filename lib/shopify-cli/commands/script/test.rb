require "shopify_cli"

module ShopifyCli
  module Commands
    class Script
      class Test < ShopifyCli::SubCommand
        CMD_DESCRIPTION = "Runs unit tests"
        RUNNING_MSG = "Running tests..."
        CMD_USAGE = "test [Extension Point] [Script Name]"

        def call(args, _name)
          extension_point_type = args.shift
          return @ctx.puts(self.class.help) unless extension_point_type

          script_name = args.shift
          return @ctx.puts(self.class.help) unless script_name

          language = "ts"

          dep_manager = ScriptModule::Infrastructure::DependencyManager.for(@ctx, script_name, language)

          ScriptModule::Infrastructure::ScriptRepository.new.with_script_context(script_name) do
            unless dep_manager.installed?
              CLI::UI::Frame.open('Installing Dependencies in {{green:package.json}}...') do
                ShopifyCli::UI::RequirementSpinner.spin('Installing') do |spinner|
                  dep_manager.install
                  spinner.update_title("Installed")
                end
              end
            end
          end

          @ctx.setenv("FORCE_COLOR", "1") # without this, aspect output is not in color :(
          CLI::UI::Frame.open("Running tests") do
            ScriptModule::Application::Test.call(@ctx, language, extension_point_type, script_name)
          end
        rescue StandardError => e
          raise(ShopifyCli::Abort, e.message)
        end

        def self.help
          "#{CMD_DESCRIPTION}\nUsage: {{command:#{TOOL_NAME} #{CMD_USAGE}}}"
        end
      end
    end
  end
end
