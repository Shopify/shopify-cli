# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/file"

module ShopifyCLI
  module Theme
    class FileTest < Minitest::Test
      def setup
        super
        @file = File.new("path", root)
        @file.stubs(:path).returns(path)
      end

      def test_liquid_css_when_it_is_a_liquid_css_asset
        @file.stubs(:relative_path).returns("assets/base.css.liquid")
        assert @file.liquid_css?
      end

      def test_liquid_css_when_it_is_not_a_liquid_css_asset
        @file.stubs(:relative_path).returns("assets/base.css")
        refute @file.liquid_css?
      end

      def test_read_when_file_is_a_text
        @file.stubs(:text?).returns(true)

        @path.expects(:read).with(universal_newline: true)
        @file.read
      end

      def test_read_when_file_is_not_a_text
        @file.stubs(:text?).returns(false)

        @path.expects(:read).with(mode: "rb")
        @file.read
      end

      def test_write_when_file_parent_is_not_a_directory
        @path.parent.stubs(:directory?).returns(false)
        @path.stubs(:write)

        @path.parent.expects(:mkpath)
        @file.write("content")
      end

      def test_write_when_file_parent_is_a_directory
        @path.parent.stubs(:directory?).returns(true)
        @path.stubs(:write)

        @path.parent.expects(:mkpath).never
        @file.write("content")
      end

      def test_write_when_file_is_a_text
        @path.parent.stubs(:directory?).returns(true)
        @file.stubs(:text?).returns(true)

        @path.expects(:write).with("content", universal_newline: true)
        @file.write("content")
      end

      def test_write_when_file_is_not_a_text
        @path.parent.stubs(:directory?).returns(true)
        @file.stubs(:text?).returns(false)

        @path.expects(:write).with("content", 0, mode: "wb")
        @file.write("content")
      end

      def test_name
        file = fixture_file("layout/theme.liquid")

        expected_name = "theme.liquid"
        actual_name = file.name

        assert_equal(expected_name, actual_name)
      end

      def test_name_with_args
        file = fixture_file("layout/theme.liquid")

        expected_name = "theme"
        actual_name = file.name(".*")

        assert_equal(expected_name, actual_name)
      end

      def test_absolute_path
        absolute_path = "#{ShopifyCLI::ROOT}/layout/theme.liquid"

        realpath = stub(to_s: absolute_path)
        path = stub(realpath: realpath)
        @file.stubs(path: path)

        assert_equal(absolute_path, @file.absolute_path)
      end

      def test_relative_path
        file = fixture_file("layout/theme.liquid")

        expected_relative_path = "layout/theme.liquid"
        actual_relative_path = file.relative_path

        assert_equal(expected_relative_path, actual_relative_path)
      end

      private

      def fixture_file(file_path)
        File.new("#{ShopifyCLI::ROOT}/#{file_path}", root)
      end

      def path
        @path = mock
        @path.stubs(:parent).returns(mock)
        @path
      end

      def root
        @root = mock
        @root.stubs(:expand_path).returns(ShopifyCLI::ROOT)
        @root
      end
    end
  end
end
