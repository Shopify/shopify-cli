module Extension
  module Tasks
    module ExecuteCommands
      module OutdatedExtensionDetection
        class OutdatedCheck
          include ShopifyCLI::MethodObject

          property! :type, accepts: Models::DevelopmentServerRequirements.method(:type_supported?)
          property! :context, accepts: ShopifyCLI::Context
          property! :project, accepts: ShopifyCLI::Project, default: -> { ShopifyCLI::Project.current }

          def call
            return false if valid?(parse_package)
            context.abort(upgrade_instructions)
          end

          private

          def upgrade_instructions
            case type
            when "checkout_ui_extension"
              context.message("errors.outdated_extensions.checkout_ui_extension")
            when "product_subscription"
              context.message("errors.outdated_extensions.product_subscription")
            when "checkout_post_purchase"
              context.message("errors.outdated_extensions.checkout_post_purchase")
            else
              context.message("errors.outdated_extensions.unknown")
            end
          end

          def parse_package
            File.open(Pathname(project.directory).join("package.json")) do |file|
              Models::NpmPackage.parse(file)
            end
          end

          def valid?(package)
            case type
            when "checkout_ui_extension", "product_subscription", "checkout_post_purchase"
              package.dev_dependency?("@shopify/shopify-cli-extensions") &&
                package.script?("build") &&
                package.script?("develop")
            else
              true
            end
          end
        end

        def call(*)
          return super unless Models::DevelopmentServerRequirements.supported?(type)
          OutdatedCheck.call(type: type, context: context).then { super }
        end
      end
    end
  end
end
