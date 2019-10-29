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
          return puts CLI::UI.fmt(self.class.help) unless extension_point_type

          script_name = args.shift
          return puts CLI::UI.fmt(self.class.help) unless script_name

          puts CLI::UI.fmt(RUNNING_MSG)
          ScriptModule::Application::Test.call("ts", extension_point_type, script_name)
        end

        def self.help
          "#{CMD_DESCRIPTION}\nUsage: {{command:#{TOOL_NAME} #{CMD_USAGE}}}"
        end
      end
    end
  end
end
