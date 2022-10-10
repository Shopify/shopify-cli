require "test_helper"

module ShopifyCLI
  class UtilitiesTest < MiniTest::Test
    def test_version_dropping_pre_and_build
      # Given
      version = Semantic::Version.new("1.2.3-pre+1")

      # When
      got = Utilities.version_dropping_pre_and_build(version)

      # Then
      assert_equal Semantic::Version.new("1.2.3"), got
    end

    def test_directory_returns_nil_when_search_path_exhausted
      File.stubs(:exist?).returns(true)
      assert_nil(Utilities.directory("foo.txt", "/"))
      assert_nil(Utilities.directory("foo.txt", "C:/"))
    end

    def test_directory_returns_nil_when_file_not_found
      File.stubs(:exist?).returns(false)
      assert_nil(Utilities.directory("foo.txt", "/some/path/inside/the/system"))
    end

    def test_directory_returns_directory_when_file_found
      File.expects(:exist?).times(3).returns(false, false, true)
      path = "/some/path/inside/the/system"
      assert_equal(path.split("/")[0...-2].join("/"), Utilities.directory("foo.txt", path))
    end

    def test_deep_merge_merges_two_hashes_deeply
      first = { a: { b: 1, c: 1 } }
      second = { a: { b: 2 } }
      assert_equal({ a: { b: 2, c: 1 } }, Utilities.deep_merge(first, second))
    end
  end
end
