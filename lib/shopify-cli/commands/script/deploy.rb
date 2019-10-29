require 'shopify_cli'

module ShopifyCli
  module Commands
    class Script
      class Deploy < ShopifyCli::SubCommand
        CMD_DESCRIPTION = "Deploy a script to the extension platform"
        CMD_USAGE = "deploy <Extension Point> <Script Name> --shop [id] --config [json]"

        FAILED_TO_BUILD_MESSAGE = "Failed to build"
        DEPLOY_SUCCEEDED_MSG = "Deploy was successful"
        BUILDING_MSG = "Building..."
        DEPLOYING_MSG = "Deploying..."

        INVALID_EXTENSION_POINT = "Invalid extension point %{extension_point}"
        SCRIPT_NOT_FOUND = "Could not find script %{script_name} for extension point %{extension_point}"

        def call(args, _name)
          extension_point = args.shift
          return puts CLI::UI.fmt(self.class.help) unless extension_point

          name = args.shift
          return puts CLI::UI.fmt(self.class.help) unless name

          shop_id =
            if args.include?("--shop")
              index = args.index("--shop")
              args[index + 1]
            end

          config_value =
            if args.include?("--config")
              index = args.index("--config")
              args[index + 1]
            end

          puts CLI::UI.fmt(BUILDING_MSG)
          ScriptModule::Application::Build.call("ts", extension_point, name)

          puts CLI::UI.fmt(DEPLOYING_MSG)
          ScriptModule::Application::Deploy.call("ts", extension_point, name, shop_id, config_value)

          puts CLI::UI.fmt(DEPLOY_SUCCEEDED_MSG)
        rescue ScriptModule::Domain::ScriptNotFoundError
          puts CLI::UI.fmt(format(SCRIPT_NOT_FOUND, script_name: name, extension_point: extension_point))
        rescue ScriptModule::Domain::InvalidExtensionPointError
          puts CLI::UI.fmt(format(INVALID_EXTENSION_POINT, extension_point: extension_point))
        rescue ScriptModule::Domain::ServiceFailureError => e
          warn("Command failed: #{e.inspect}")
        end

        def self.help
          <<~HELP
            #{CMD_DESCRIPTION}
              Usage: {{command:#{ShopifyCli::TOOL_NAME} #{CMD_USAGE}}}
          HELP
        end
      end
    end
  end
end
