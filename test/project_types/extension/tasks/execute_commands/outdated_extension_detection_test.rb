require "test_helper"

module Extension
  module Tasks
    module ExecuteCommands
      class OutdatedExtensionDetectionTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def dummy_command
          Class.new(Base) do
            include ShopifyCLI::MethodObject

            property :type
            property! :executed, default: false

            def call
              self.executed = true
              :success
            end
          end
        end

        def test_bypasses_outdated_check_for_extensions_that_do_not_support_the_new_development_server
          Models::DevelopmentServerRequirements.expects(:supported?).returns(false)
          OutdatedExtensionDetection::OutdatedCheck.expects(:call).never
          assert_equal :success, dummy_command.call(type: "checkout_ui_extension").unwrap!
        end

        def test_performs_outdated_check_for_extensions_supporting_the_new_development_server
          Models::DevelopmentServerRequirements.expects(:supported?).returns(true)
          OutdatedExtensionDetection::OutdatedCheck
            .expects(:call).with(type: "checkout_ui_extension").once
            .returns(ShopifyCLI::Result.wrap(true))
          assert_equal :success, dummy_command.call(type: "checkout_ui_extension").unwrap!
        end

        def test_aborts_command_execution_if_outdated_check_fails
          Models::DevelopmentServerRequirements.expects(:supported?).returns(true)
          OutdatedExtensionDetection::OutdatedCheck
            .expects(:call).with(type: "checkout_ui_extension").once
            .returns(ShopifyCLI::Result.wrap(RuntimeError.new))

          dummy_command_instance = dummy_command.new(type: "checkout_ui_extension")
          assert_raises(RuntimeError) { dummy_command_instance.call.unwrap! }
          refute dummy_command_instance.executed
        end
      end

      class OutdatedCheckTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_raises_with_upgrade_instructions_if_package_json_is_outdated
          package_json = StringIO.new(<<~JSON)
          {
            "name": "my-extension",
            "scripts": {
              "start": "some command",
              "build": "some other command"
            }
          }
          JSON

          File
            .expects(:open)
            .with(Pathname(ShopifyCLI::Project.current.directory).join("package.json"))
            .returns(Models::NpmPackage.parse(package_json))

          message = <<~TEXT.strip
            Please update your package.json as follows:
            * Replace the development dependency @shopify/checkout-ui-extensions-run
              with @shopify/shopify-cli-extensions
            * Remove the start and server script
            * Add a develop script: shopify-cli-extensions develop
            * Change then build script to: shopify-cli-extensions build
          TEXT

          result = OutdatedExtensionDetection::OutdatedCheck.call(type: "checkout_ui_extension")
          assert_predicate(result, :failure?)
          assert_equal message, result.error.message
        end
      end
    end
  end
end
