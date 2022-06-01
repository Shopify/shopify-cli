# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"
module Extension
  module Models
    module SpecificationHandlers
      class WebPixelExtensionTest < MiniTest::Test
        include ExtensionTestHelpers
        CONFIG_CONTENTS = <<~EOS
          runtime_context: strict
          version: "1"
          configuration:
            type: object
            fields:
              trackingId:
                name: Unique Tracking Id
                description: Tracking Id to uniquely identify shop/merchant
                type: single_line_text_field
        EOS

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)

          specifications = DummySpecifications.build(identifier: "web_pixel_extension", surface: "admin")

          @identifier = "WEB_PIXEL_EXTENSION"
          @web_pixel_extension = specifications[@identifier]
          @context.root = Dir.mktmpdir
        end

        def test_config_raises_file_read_error_if_config_is_missing
          err = assert_raises(CLI::Kit::Abort) do
            @web_pixel_extension.config(@context)
          end
          assert_equal("{{x}} There was a problem reading " +
            WebPixelExtensionUtils::ScriptConfigYmlRepository.filename.to_s,
            err.message)
        end

        def test_config_raises_file_read_errorr_if_js_is_missing
          create(@context, "0", CONFIG_CONTENTS)
          File.delete(File.join(@context.root, "build/main.js"))
          err = assert_raises(CLI::Kit::Abort) do
            @web_pixel_extension.config(@context)
          end
          assert_equal("{{x}} There was a problem reading build/main.js", err.message)
        end

        def test_raises_missing_config_key_error_if_expected_key_is_missing
          err = assert_raises(CLI::Kit::Abort) do
            @web_pixel_extension.access_config_property(@context, {}, "some_key")
          end
          assert_equal("{{x}} Configuration is missing key: some_key", err.message)
        end

        def test_raises_invalid_config_value_error_if_unable_to_process_value
          err = assert_raises(CLI::Kit::Abort) do
            @web_pixel_extension.access_config_property(@context, { "some_key" => "some_value" },
              "some_key") do |_v|
              raise RuntimeError
            end
          end
          assert_equal("{{x}} Configuration value is invalid: some_key", err.message)
        end

        def test_config_implementation
          create(@context, "0", CONFIG_CONTENTS)
          payload = @web_pixel_extension.config(@context)
          assert_equal("strict", payload[:runtime_context])
          assert_equal("MA==", payload[:serialized_script])
          assert_equal("1", payload[:config_version])
          config = JSON.parse(payload[:runtime_configuration_definition])
          assert_equal({ "type" => "object",
              "fields" => { "trackingId" => { "name" => "Unique Tracking Id",
                                              "description" => "Tracking Id to uniquely identify shop/merchant",
                                              "type" => "single_line_text_field" } } },
            config)
        end

        private

        def create_file(file_path, contents = nil)
          if contents
            File.open(file_path, "w") { |file| file.write(contents) }
          else
            FileUtils.touch(file_path)
          end
        end

        def create(context, script_contents, config_contents, **_args)
          create_file(File.join(context.root, "extension.config.yml"),
            config_contents)
          Dir.mkdir(File.join(context.root, "build"))
          create_file(File.join(context.root, "build/main.js"), script_contents)
        end
      end
    end
  end
end
