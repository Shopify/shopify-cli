# frozen_string_literal: true
require 'project_types/script/test_helper'

module Script
  module Commands
    class EnableTest < MiniTest::Test
      include TestHelpers::FakeFS

      def setup
        super
        @cmd = Enable
        @cmd.ctx = @context
        @configuration = { entries: [] }
        @ep_type = 'discount'
        @script_name = 'script'
        @api_key = 'apikey'
        @shop_domain = 'my-test-shop.myshopify.com'
        @script_project = TestHelpers::FakeScriptProject.new(
          language: @language,
          extension_point_type: @ep_type,
          script_name: @script_name
        )
        ScriptProject.stubs(:current).returns(@script_project)
        @script_project.stubs(:env).returns({ api_key: @api_key, shop: @shop_domain })
      end

      def test_calls_application_enable
        ShopifyCli::Tasks::EnsureEnv
          .any_instance.expects(:call)
          .with(@context, required: [:api_key, :secret, :shop])

        expect_successful_enable(@configuration)

        capture_io do
          perform_command
        end
      end

      def test_help
        ShopifyCli::Context
          .expects(:message)
          .with('script.enable.help', ShopifyCli::TOOL_NAME)
        Script::Commands::Enable.help
      end

      def test_calls_application_enable_error
        ShopifyCli::Tasks::EnsureEnv
          .any_instance.expects(:call)
          .with(@context, required: [:api_key, :secret, :shop])
        Script::Layers::Application::EnableScript.expects(:call).with(
          ctx: @context,
          api_key: @api_key,
          shop_domain: @shop_domain,
          configuration: @configuration,
          extension_point_type: @ep_type,
          title: @script_name
        ).raises(StandardError)

        @context
          .expects(:puts)
          .with(@context.message(
            'script.enable.script_enabled',
            api_key: @api_key,
            shop_domain: @shop_domain,
            type: @ep_type.capitalize,
            title: @script_name
          ))
          .never

        @context
          .expects(:puts)
          .with(@context.message('script.enable.info'))
          .never

        assert_raises StandardError do
          capture_io do
            perform_command
          end
        end
      end

      def test_calls_application_enable_with_configuration_properties
        expected_configuration = {
          entries: [
            {
              key: "key1",
              value: "value1",
            },
            {
              key: "key2",
              value: "value2",
            },
          ],
        }

        expect_successful_enable(expected_configuration)

        capture_io do
          perform_command(config_props: "key1:value1,key2:value2")
        end
      end

      def test_with_config_props_with_spaces
        expected_configuration = {
          entries: [
            {
              key: "key1",
              value: "value1",
            },
            {
              key: "key2",
              value: "with spaces",
            },
          ],
        }

        expect_successful_enable(expected_configuration)

        capture_io do
          perform_command(config_props: "key1:value1 , key2:with spaces")
        end
      end

      def test_should_call_error_handler_when_given_invalid_config_props
        Script::UI::ErrorHandler.expects(:pretty_print_and_raise).with(
          instance_of(Errors::InvalidConfigProps),
          failed_op: @context.message('script.enable.error.operation_failed')
        )

        capture_io do
          perform_command(config_props: "key1:value1:value2")
        end
      end

      def test_calls_application_enable_with_configuration_file
        File.open("enable_config_file.yml", "w+") { |file| file.write("key1: \"value1\"\nkey2: \"value2\"") }
        expected_configuration = {
          entries: [
            {
              key: "key1",
              value: "value1",
            },
            {
              key: "key2",
              value: "value2",
            },
          ],
        }

        expect_successful_enable(expected_configuration)

        capture_io do
          perform_command(config_file_path: "enable_config_file.yml")
        end
      end

      def test_calls_application_enable_with_configuration_file_and_properties_override
        File.open("enable_config_file.yml", "w+") { |file| file.write("key1: \"value1\"\nkey2: \"value2\"") }
        expected_configuration = {
          entries: [
            {
              key: "key1",
              value: "overriddenValue",
            },
            {
              key: "key2",
              value: "value2",
            },
          ],
        }

        expect_successful_enable(expected_configuration)

        capture_io do
          perform_command(config_props: "key1:overriddenValue", config_file_path: "enable_config_file.yml")
        end
      end

      def test_calls_application_enable_with_invalid_configuration_file
        File.open("enable_config_file.yml", "w+") { |file| file.write("key1 \"value1\"\nkey2: \"value2\"") }

        Script::UI::ErrorHandler
          .expects(:pretty_print_and_raise)
          .with(instance_of(Errors::InvalidConfigYAMLError))

        capture_io do
          perform_command(config_file_path: "enable_config_file.yml")
        end
      end

      def test_calls_application_enable_with_missing_configuration_file
        Script::UI::ErrorHandler
          .expects(:pretty_print_and_raise)
          .with(instance_of(Errors::InvalidConfigYAMLError))

        capture_io do
          perform_command(config_file_path: "enable_config_file.yml")
        end
      end

      private

      def expect_successful_enable(configuration)
        Script::Layers::Application::EnableScript.expects(:call).with(
          ctx: @context,
          api_key: @api_key,
          shop_domain: @shop_domain,
          configuration: configuration,
          extension_point_type: @ep_type,
          title: @script_name
        )

        @context
          .expects(:puts)
          .with(@context.message(
            'script.enable.script_enabled',
            api_key: @api_key,
            shop_domain: @shop_domain,
            type: @ep_type.capitalize,
            title: @script_name
          ))

        @context
          .expects(:puts)
          .with(@context.message('script.enable.info'))
      end

      def perform_command(config_props: nil, config_file_path: nil)
        env_contents = "SHOPIFY_API_KEY=apikey\n" \
                       "SHOPIFY_API_SECRET=secret\n" \
                       "HOST=https://example.com\n" \
                       "SHOP=my-test-shop.myshopify.com\n" \
                       "AWSKEY=awskey"
        command = ["enable"]
        command << "--config_props=#{config_props}" unless config_props.nil?
        command << "--config_file=#{config_file_path}" unless config_file_path.nil?
        ShopifyCli::Core::Monorail.stubs(:log).yields
        File.open(".env", "w+") { |file| file.write(env_contents) }
        run_cmd(command, false)
      end
    end
  end
end
