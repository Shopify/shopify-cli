require "test_helper"

module Extension
  module Tasks
    module ExecuteCommands
      class OutdatedExtensionDetectionTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_bypasses_outdated_check_for_extensions_that_do_not_support_the_new_development_server
          Models::DevelopmentServerRequirements.expects(:supported?).returns(false)
          OutdatedExtensionDetection::OutdatedCheck.expects(:call).never
          assert_equal :success, dummy_command.call(type: "checkout_ui_extension", context: fake_context).unwrap!
        end

        def test_performs_outdated_check_for_extensions_supporting_the_new_development_server
          Models::DevelopmentServerRequirements.expects(:supported?).returns(true)
          OutdatedExtensionDetection::OutdatedCheck
            .expects(:call).with(has_entries(type: "checkout_ui_extension")).once
            .returns(ShopifyCLI::Result.wrap(true))
          assert_equal :success, dummy_command.call(type: "checkout_ui_extension", context: fake_context).unwrap!
        end

        def test_aborts_command_execution_if_outdated_check_fails
          Models::DevelopmentServerRequirements.expects(:supported?).returns(true)
          OutdatedExtensionDetection::OutdatedCheck
            .expects(:call).with(has_entries(type: "checkout_ui_extension")).once
            .returns(ShopifyCLI::Result.wrap(RuntimeError.new))

          dummy_command_instance = dummy_command.new(type: "checkout_ui_extension", context: fake_context)
          assert_raises(RuntimeError) { dummy_command_instance.call.unwrap! }
          refute dummy_command_instance.executed
        end

        private

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

        def fake_context
          TestHelpers::FakeContext.new
        end
      end

      class OutdatedCheckTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_raises_with_upgrade_instructions_if_package_json_is_outdated
          File.write("package.json", <<~JSON)
            {
              "name": "my-extension",
              "scripts": {
                "start": "some command",
                "build": "some other command"
              }
            }
          JSON

          message = <<~TEXT.strip
            {{x}} Please update your package.json as follows:
            * Replace the development dependency @shopify/checkout-ui-extensions-run
              with @shopify/shopify-cli-extensions
            * Remove the start and server script
            * Add a develop script: shopify-cli-extensions develop
            * Change then build script to: shopify-cli-extensions build
          TEXT

          result = OutdatedExtensionDetection::OutdatedCheck.call(type: "checkout_ui_extension",
            context: TestHelpers::FakeContext.new)
          assert_predicate(result, :failure?)
          assert_equal message, result.error.message
        ensure
          FileUtils.rm("package.json")
        end

        def test_does_not_raise_with_upgrade_instructions_if_package_json_is_up_to_date
          package_json = StringIO.new(<<~JSON)
            {
              "name": "my-extension",
              "devDependencies": {
                "@shopify/shopify-cli-extensions": "^0.2.0"
              },
              "scripts": {
                "build": "some command",
                "develop": "some other command"
              }
            }
          JSON

          File
            .expects(:open)
            .with(Pathname(ShopifyCLI::Project.current.directory).join("package.json"))
            .returns(Models::NpmPackage.parse(package_json))

          result = OutdatedExtensionDetection::OutdatedCheck.call(type: "checkout_ui_extension",
            context: TestHelpers::FakeContext.new)
          assert_predicate(result, :success?)
        ensure
          $debug = false
        end
      end
    end
  end
end
