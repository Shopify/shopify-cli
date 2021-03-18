# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"
require "pry"

module Extension
  module Models
    module SpecificationHandlers
      class OnlineStoreAppExtensionTest < MiniTest::Test
        include ExtensionTestHelpers

        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)
          specifications = DummySpecifications.build(identifier: "online_store_app_extension")
          @identifier = "ONLINE_STORE_APP_EXTENSION"
          @spec = specifications[@identifier]
          @context.root = Dir.mktmpdir
        end

        def teardown
          FileUtils.remove_dir(@context.root)
        end

        def test_context_root
          old_root = @context.root
          dir_name = "test_app"
          @spec.create(dir_name, @context)
          assert_equal(@context.root, File.join(old_root, dir_name))
          assert(File.exist?(@context.root))
        end

        def test_encodes_config
          block_content = "{% comment %} I'm a block {% endcomment %}"
          write("blocks/app.liquid", block_content)

          expected = {
            "theme_extension" => {
              "files" => {
                "blocks/app.liquid" => Base64.encode64(block_content),
              },
            },
          }
          assert_equal(expected, @spec.config(@context))
        end

        def test_validates_buckets
          write("invalid/readme.txt", "hello")
          assert_raises Extension::Errors::InvalidDirectoryError do
            @spec.config(@context)
          end
        end

        def test_validates_nested_files
          write("invalid/blocks/app.liquid", "hello")
          assert_raises Extension::Errors::InvalidDirectoryError do
            @spec.config(@context)
          end
        end

        def test_skips_build
          assert @spec.specification.options[:skip_build]
        end

        private

        def write(filename, content)
          filename = File.join(@context.root, filename)
          FileUtils.mkdir_p(File.dirname(filename))
          File.write(filename, content)
        end
      end
    end
  end
end
