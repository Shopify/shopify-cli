# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Models
    module SpecificationHandlers
      class ThemeAppExtensionTest < MiniTest::Test
        include ExtensionTestHelpers

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
          specifications = DummySpecifications.build(identifier: "theme_app_extension")
          @identifier = "THEME_APP_EXTENSION"
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

        def test_handles_unicode
          block_content = "{% comment %} I'm a 🚀 block {% endcomment %}"
          write("blocks/app.liquid", block_content)

          expected = {
            "theme_extension" => {
              "files" => {
                "blocks/app.liquid" => Base64.encode64(block_content),
              },
            },
          }

          original_encoding = Encoding.default_external
          Encoding.default_external = "ascii"

          config = @spec.config(@context)
          assert_equal(expected, config)

          decoded_config = Base64.decode64(config.dig("theme_extension", "files", "blocks/app.liquid"))
            .force_encoding("utf-8")
          assert_equal(block_content, decoded_config)
        ensure
          Encoding.default_external = original_encoding
        end

        def test_handles_binary
          binary_data = "\x00\x01\x02\r\n\x03\x04".encode("BINARY")
          write("assets/test.png", binary_data, mode: "wb", encoding: "BINARY")

          expected = {
            "theme_extension" => {
              "files" => {
                "assets/test.png" => Base64.encode64(binary_data),
              },
            },
          }

          config = @spec.config(@context)
          assert_equal(expected, config)
        end

        def test_files_at_root_are_ignored
          write("readme.txt", "hello")
          config = @spec.config(@context)
          refute_includes(config["theme_extension"]["files"], "readme.txt")
        end

        def test_validates_buckets
          write("invalid/readme.txt", "hello")
          assert_raises Extension::Errors::InvalidFilenameError do
            @spec.config(@context)
          end
        end

        def test_validates_nested_files
          write("invalid/blocks/app.liquid", "hello")
          assert_raises Extension::Errors::InvalidFilenameError do
            @spec.config(@context)
          end
        end

        def test_skips_build
          assert(@spec.specification.options[:skip_build])
        end

        def test_max_filesize
          stub_const(ThemeAppExtension, :BUNDLE_SIZE_LIMIT, 50) do
            write("assets/test.png", "1" * 1000)
            assert_raises Extension::Errors::BundleTooLargeError do
              @spec.config(@context)
            end
          end
        end

        def test_bad_asset_types
          ThemeAppExtension::SUPPORTED_ASSET_EXTS.each do |ext|
            write("assets/test#{ext}1", "hello")
            assert_raises Extension::Errors::InvalidFilenameError do
              @spec.config(@context)
            end
          end
        end

        def test_bad_locale_types
          ThemeAppExtension::SUPPORTED_LOCALE_EXTS.each do |ext|
            write("locales/test#{ext}1", "hello")
            assert_raises Extension::Errors::InvalidFilenameError do
              @spec.config(@context)
            end
          end
        end

        def test_too_much_liquid
          stub_const(ThemeAppExtension, :LIQUID_SIZE_LIMIT, 50) do
            write("blocks/app1.liquid", "1" * 25)
            write("blocks/app2.liquid", "2" * 26)
            assert_raises Extension::Errors::BundleTooLargeError do
              @spec.config(@context)
            end
          end
        end

        def test_locales_does_not_impact_liquid_limit
          stub_const(ThemeAppExtension, :LIQUID_SIZE_LIMIT, 50) do
            write("locales/en.default.json", "1" * 25)
            write("locales/en.default.schema.json", "2" * 26)
            assert_nothing_raised do
              @spec.config(@context)
            end
          end
        end

        private

        def write(filename, content, mode: "w", encoding: "utf-8")
          filename = File.join(@context.root, filename)
          FileUtils.mkdir_p(File.dirname(filename))
          File.write(filename, content, mode: mode, encoding: encoding)
        end

        def stub_const(object, name, value)
          original = object.const_get(name)
          silent_const_set(object, name, value)
          yield
        ensure
          silent_const_set(object, name, original)
        end

        def silent_const_set(object, name, value)
          old_verbose = $VERBOSE
          $VERBOSE = nil
          object.const_set(name, value)
          $VERBOSE = old_verbose
        end
      end
    end
  end
end
