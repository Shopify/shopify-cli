# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"
module Extension
  module Models
    module SpecificationHandlers
      module WebPixelExtensionUtils
        class ScriptConfigRepositoryTest < MiniTest::Test
          include ExtensionTestHelpers

          def setup
            super
            ShopifyCLI::ProjectType.load_type(:extension)

            specifications = DummySpecifications.build(identifier: "web_pixel_extension", surface: "admin")

            @identifier = "WEB_PIXEL_EXTENSION"
            @web_pixel_extension = specifications[@identifier]
            @context.root = Dir.mktmpdir
          end

          def test_script_config_yml_repo_reads_valid_yml
            File.open("#{@context.root}/extension.config.yml", "w") do |f|
              f.write(
                <<-eos
              runtime_context: sandbox
              version: "2"
              eos

              )
            end
            yml_content = ScriptConfigYmlRepository.new(ctx: @context).get!.content
            assert_equal({ "runtime_context" => "sandbox", "version" => "2" }, yml_content)
          end

          def test_script_config_yml_repo_raises_error_if_file_is_not_present
            assert_raises(RuntimeError) do
              ScriptConfigYmlRepository.new(ctx: @context).get!.content
            end
          end
        end
      end
    end
  end
end
