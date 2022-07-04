require "test_helper"

module ShopifyCLI
  module Core
    class CliVersionTest < MiniTest::Test
      include TestHelpers::Project

      def test_directory_recurses
        Dir.mktmpdir do |dir|
          Dir.stubs(:pwd).returns("#{dir}/a/b/c/d")
          FileUtils.mkdir_p("#{dir}/a/b/c/d")
          refute(CliVersion.using_3_0?)
          FileUtils.touch("#{dir}/shopify.app.toml")
          assert(CliVersion.using_3_0?)
        end
      end
    end
  end
end
