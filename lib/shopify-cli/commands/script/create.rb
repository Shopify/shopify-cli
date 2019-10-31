require 'shopify_cli'

module ShopifyCli
  module Commands
    class Script
      class Create < ShopifyCli::SubCommand
        CMD_DESCRIPTION = "Create a new script for an extension point from the default template"
        CMD_USAGE = "create <Extension Point> <Script Name>"
        CREATED_NEW_SCRIPT_MSG = "Created new script at %{script_id}"
        INVALID_EXTENSION_POINT = "Invalid extension point %{extension_point}"

        def call(args, _name)
          extension_point = args.shift
          return @ctx.puts(CLI::UI.fmt(self.class.help)) unless extension_point

          name = args.shift
          return @ctx.puts(CLI::UI.fmt(self.class.help)) unless name

          language = if args.include?("--language")
            index = args.index("--language")
            args[index + 1]
          else
            "ts"
          end

          return puts CLI::UI.fmt(self.class.help) unless ScriptModule::LANGUAGES.include?(language)

          bootstrap(language, extension_point, name)
        end

        def self.help
          <<~HELP
            #{CMD_DESCRIPTION}
              Usage: {{command:#{ShopifyCli::TOOL_NAME} #{CMD_USAGE}}}
          HELP
        end

        private

        def bootstrap(language, extension_point, name)
          script = ScriptModule::Application::Bootstrap.call(language, extension_point, name)
          puts CLI::UI.fmt(format(CREATED_NEW_SCRIPT_MSG, script_id: script.id))
        rescue ScriptModule::Domain::InvalidExtensionPointError
          puts CLI::UI.fmt(format(INVALID_EXTENSION_POINT, extension_point: extension_point))
        end
      end
    end
  end
end
