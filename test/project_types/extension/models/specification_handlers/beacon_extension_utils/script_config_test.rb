# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"
module Extension
  module Models
    module SpecificationHandlers
      module BeaconExtensionUtils
        class ScriptConfigTest < MiniTest::Test
          include ExtensionTestHelpers
          def setup
            super
            ShopifyCLI::ProjectType.load_type(:extension)

            specifications = DummySpecifications.build(identifier: "beacon_extension", surface: "admin")

            @identifier = "BEACON_EXTENSION"
            @beacon_extension = specifications[@identifier]
            @context.root = Dir.mktmpdir
          end

          def test_script_config_parses_valid_content
            content = {
              "runtime_context" => "sandbox",
              "version" => 2,
              "configuration" => {

              },
            }

            script_config = Extension::Models::SpecificationHandlers::BeaconExtensionUtils::ScriptConfig.new(
              content: content, filename: "some-file-name.yml"
            )
            assert_equal({
              "runtime_context" => "sandbox",
              "version" => 2,
              "configuration" => {

              },
            }, script_config.content)
            assert_equal("2", script_config.version)
            assert_equal("some-file-name.yml", script_config.filename)
          end

          def test_script_config_raises_error_if_expected_field_is_missing
            content = {
              "runtime_context" => "sandbox",
              "configuration" => {

              },
            }
            assert_raises(RuntimeError) do
              Extension::Models::SpecificationHandlers::BeaconExtensionUtils::ScriptConfig.new(content: content,
                filename: "some-file-name.yml")
            end
          end
        end
      end
    end
  end
end
