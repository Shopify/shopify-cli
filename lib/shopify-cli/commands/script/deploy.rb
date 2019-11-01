require 'shopify_cli'

module ShopifyCli
  module Commands
    class Script
      class Deploy < ShopifyCli::SubCommand
        CMD_DESCRIPTION = "Deploy a script to the extension platform"
        CMD_USAGE = "script deploy <Extension Point> <Script Name> <API Key>"

        FAILED_TO_BUILD_MESSAGE = "Failed to build"
        DEPLOY_SUCCEEDED_MSG = "{{v}} %{extension_point} script %{script_name}" \
        "is deployed to app (API_KEY: {{green:%{app_key}}})"
        BUILDING_MSG = "Building"
        DEPLOYING_MSG = "Deploying"
        BUILT_MSG = "Built"
        DEPLOYED_MSG = "Deployed"

        INVALID_EXTENSION_POINT = "Invalid extension point %{extension_point}"
        SCRIPT_NOT_FOUND = "Could not find script %{script_name} for extension point %{extension_point}"

        options do |parser, flags|
          parser.on('--app_key=APPKEY') { |t| flags[:app_key] = t }
          parser.on('--language=LANGUAGE') { |t| flags[:language] = t }
        end

        def call(args, _name)
          form = Forms::DeployScript.ask(@ctx, args, options.flags)
          return @ctx.puts(self.class.help) unless form
          name = form.name
          extension_point = form.extension_point

          app_key = form.app_key
          language = form.language

          return @ctx.puts(self.class.help) unless ScriptModule::LANGUAGES.include?(language)

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

          deploy_package = nil
          CLI::UI::Spinner.spin(BUILDING_MSG) do |spinner|
            deploy_package = ScriptModule::Application::Build.call(@ctx, language, extension_point, name)
            spinner.update_title(BUILT_MSG)
          end

          CLI::UI::Spinner.spin(DEPLOYING_MSG) do |spinner|
            deploy_package.deploy(ScriptModule::Infrastructure::ScriptService.new(ctx: @ctx), app_key)
            spinner.update_title(DEPLOYED_MSG)
          end

          @ctx.puts(format(DEPLOY_SUCCEEDED_MSG, script_name: name, extension_point: extension_point, app_key: app_key))
        rescue ScriptModule::Domain::ScriptNotFoundError
          @ctx.puts(format(SCRIPT_NOT_FOUND, script_name: name, extension_point: extension_point))
        rescue ScriptModule::Domain::InvalidExtensionPointError
          @ctx.puts(format(INVALID_EXTENSION_POINT, extension_point: extension_point))
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
