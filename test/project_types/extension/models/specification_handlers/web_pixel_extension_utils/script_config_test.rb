# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"
module Extension
  module Models
    module SpecificationHandlers
      module WebPixelExtensionUtils
        class ScriptConfigTest < MiniTest::Test
          include ExtensionTestHelpers
          def setup
            super
            ShopifyCLI::ProjectType.load_type(:extension)

            specifications = DummySpecifications.build(identifier: "web_pixel_extension", surface: "admin")

            @identifier = "WEB_PIXEL_EXTENSION"
            @web_pixel_extension = specifications[@identifier]
            @context.root = Dir.mktmpdir
          end

          def test_script_config_parses_valid_content
            content = {
              "runtime_context" => "strict",
              "version" => 2,
              "configuration" => {

              },
            }

            script_config = Extension::Models::SpecificationHandlers::WebPixelExtensionUtils::ScriptConfig.new(
              content: content, filename: "some-file-name.yml"
            )
            assert_equal({
              "runtime_context" => "strict",
              "version" => 2,
              "configuration" => {

              },
            }, script_config.content)
            assert_equal("2", script_config.version)
            assert_equal("some-file-name.yml", script_config.filename)
          end

          def test_script_config_raises_error_if_expected_field_is_missing
            content = {
              "runtime_context" => "strict",
              "configuration" => {

              },
            }
            assert_raises(RuntimeError) do
              Extension::Models::SpecificationHandlers::WebPixelExtensionUtils::ScriptConfig.new(content: content,
                filename: "some-file-name.yml")
            end
          end
        end
      end
    end
  end
end
