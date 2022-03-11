module Extension
  module Tasks
    module ExecuteCommands
      module OutdatedExtensionDetection
        class OutdatedCheck
          include ShopifyCLI::MethodObject

          property! :type, accepts: Models::DevelopmentServerRequirements.method(:type_supported?)
          property! :project, accepts: ShopifyCLI::Project, default: -> { ShopifyCLI::Project.current }

          def call
            return if valid?(parse_package)
            raise upgrade_instructions
          end

          private

          def upgrade_instructions
            case type
            when "checkout_ui_extension"
              <<~TEXT.strip
                Please update your package.json as follows:
                * Replace the development dependency @shopify/checkout-ui-extensions-run
                  with @shopify/shopify-cli-extensions
                * Remove the start and server script
                * Add a develop script: shopify-cli-extensions develop
                * Change then build script to: shopify-cli-extensions build
              TEXT
            else
              <<~TEXT.strip
              Please refer to the documentation for more information on how to upgrade your extension:
              https://shopify.dev/apps/app-extensions
              TEXT
            end
          end

          def parse_package
            File.open(Pathname(project.directory).join("package.json")) do |file|
              Models::NpmPackage.parse(file)
            end
          end

          def valid?(package)
            case type
            when "checkout_ui_extension"
              package.dependency?("@shopify/checkout-ui-extensions") &&
                package.script?("build") &&
                package.script?("develop")
            else
              true
            end
          end
        end

        def call(*)
          return super unless Models::DevelopmentServerRequirements.supported?(type)
          OutdatedCheck.call(type: type).then { super }
        end
      end
    end
  end
end
