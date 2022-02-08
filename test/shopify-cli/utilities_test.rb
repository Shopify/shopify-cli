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
  end
end
