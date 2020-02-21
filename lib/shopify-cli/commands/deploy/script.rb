require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy
      class Script < ShopifyCli::Command
        CMD_DESCRIPTION = "Deploy a script to the extension platform"
        CMD_USAGE = "deploy <API Key>"

        FAILED_TO_BUILD_MESSAGE = "Failed to build"
        DEPLOY_SUCCEEDED_MSG = "{{v}} %{extension_point} script %{script_name} " \
        "is deployed to app (API_KEY: {{green:%{api_key}}})"
        BUILDING_MSG = "Building"
        DEPLOYING_MSG = "Deploying"
        BUILT_MSG = "Built"
        DEPLOYED_MSG = "Deployed"

        INVALID_EXTENSION_POINT = "Invalid extension point %{extension_point}"
        SCRIPT_NOT_FOUND = "Could not find script %{script_name} for extension point %{extension_point}"

        options do |parser, flags|
          parser.on('--api_key=APIKEY') { |t| flags[:api_key] = t }
          parser.on('--language=LANGUAGE') { |t| flags[:language] = t }
        end

        def call(args, _name)
          form = Forms::DeployScript.ask(@ctx, args, options.flags)
          return @ctx.puts(self.class.help) unless form

          api_key = form.api_key

          project = ShopifyCli::ScriptModule::ScriptProject.current
          extension_point_type = project.extension_point_type
          script_name = project.script_name
          language = project.language

          return @ctx.puts(self.class.help) unless ScriptModule::LANGUAGES.include?(language)

          dep_manager = ScriptModule::Infrastructure::DependencyManager.for(@ctx, script_name, language)
          dep_manager.install unless dep_manager.installed?

          ShopifyCli::UI::StrictSpinner.spin(BUILDING_MSG) do |spinner|
            ScriptModule::Application::Build.call(language, extension_point_type, script_name)
            spinner.update_title(BUILT_MSG)
          end

          ShopifyCli::UI::StrictSpinner.spin(DEPLOYING_MSG) do |spinner|
            ScriptModule::Application::Deploy.call(@ctx, language, extension_point_type, script_name, api_key)
            spinner.update_title(DEPLOYED_MSG)
          end

          @ctx.puts(
            format(
              DEPLOY_SUCCEEDED_MSG, script_name: script_name, extension_point: extension_point_type, api_key: api_key
            )
          )
        rescue ScriptModule::Domain::ScriptNotFoundError
          @ctx.puts(format(SCRIPT_NOT_FOUND, script_name: script_name, extension_point: extension_point_type))
        rescue ScriptModule::Domain::InvalidExtensionPointError
          @ctx.puts(format(INVALID_EXTENSION_POINT, extension_point: extension_point_type))
        rescue ScriptModule::Domain::ServiceFailureError => e
          warn("Command failed: #{e.inspect}")
        rescue StandardError => e
          raise(ShopifyCli::Abort, e)
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
