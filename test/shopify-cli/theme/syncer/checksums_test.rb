# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/checksums"

module ShopifyCLI
  module Theme
    class Syncer
      class ChecksumsTest < Minitest::Test
        def setup
          super
          @checksums = Checksums.new(@context)
          @checksums.stubs(theme: theme)
          @checksums.stubs(:checksum_by_key).returns({ file.relative_path => "checksum" })
        end

        def test_has_when_file_is_not_on_checksums
          @checksums.stubs(:checksum_by_key).returns({})

          refute(@checksums.has?(file))
        end

        def test_has_when_file_is_on_checksums
          assert(@checksums.has?(file))
        end

        def test_file_has_changed_when_its_changed
          @checksums.stubs(:checksum_by_key).returns({ file.relative_path => "changed" })

          assert(@checksums.file_has_changed?(file))
        end

        def test_file_has_changed_when_its_not_changed
          refute(@checksums.file_has_changed?(file))
        end

        def test_keys
          @checksums.stubs(:checksum_by_key).returns({ "path1" => "1", "path2" => "2", "path3" => "3" })

          assert_equal(["path1", "path2", "path3"], @checksums.keys.sort)
        end

        def test_setter_with_mutex
          @checksums[file.relative_path] = "changed"

          assert_equal("changed", @checksums[file.relative_path])
        end

        def test_setter_without_mutex
          @checksums.stubs(:checksums_mutex).returns(stub(synchronize: nil))
          @checksums[file.relative_path] = "changed"

          assert_equal("checksum", @checksums[file.relative_path])
        end

        def test_reject_duplicated_checksums
          @checksums.stubs(:checksum_by_key).returns({
            "file1.liquid" => "",
            "file2.liquid" => "",
            "file1" => "",
            "file2" => "",
          })

          @checksums.reject_duplicated_checksums!

          assert_equal(["file1.liquid", "file2.liquid"], @checksums.keys.sort)
        end

        private

        def file
          @file ||= stub(
            relative_path: "layout/theme.liquid",
            checksum: "checksum"
          )
        end

        def theme
          @theme ||= stub(
            :[] => file
          )
        end
      end
    end
  end
end
