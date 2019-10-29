require 'shopify_cli'

module ShopifyCli
  module Commands
    class Script
      class GenerateFromSchema < ShopifyCli::SubCommand
        CMD_DESCRIPTION = "Generate types from GraphQL schemas"
        CMD_USAGE = "generate-from-schema [Extension Point] [Script Name] [--config]"
        UNKNOWN_SCHEMA_TYPE = "Unknown schema type %{type}"
        CONFIG_FILE_NOT_FOUND = "config.schema file not found for script: %{extension}/%{script}"
        GENERATED_CONFIGURATION_MSG = "Generated types from configuration schema for script: %{extension}/%{script}"

        def call(args, _name)
          extension_point_type = args.shift
          return puts CLI::UI.fmt(self.class.help) unless extension_point_type

          script_name = args.shift
          return puts CLI::UI.fmt(self.class.help) unless script_name

          schema_type = args.shift

          case schema_type
          when "--config"
            ScriptModule::Application::GenerateFromSchema.generate_config_from_schema(extension_point_type, script_name)
            puts CLI::UI.fmt(format(GENERATED_CONFIGURATION_MSG, extension: extension_point_type, script: script_name))
          else
            puts CLI::UI.fmt(format(UNKNOWN_SCHEMA_TYPE, type: schema_type))
            puts CLI::UI.fmt(self.class.help)
          end

        rescue ScriptModule::Domain::ConfigurationFileNotFoundError
          puts CLI::UI.fmt(format(CONFIG_FILE_NOT_FOUND, script: script_name, extension: extension_point_type))
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
