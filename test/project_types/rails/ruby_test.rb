# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  class RubyTest < MiniTest::Test
    def test_ruby_matches
      context = ShopifyCLI::Context.new(env: {})
      context.expects(:capture2).with("ruby", "-v").returns(
        ["ruby 2.3.7p456 (2018-03-28 revision 63024) [universal.x86_64-darwin18]", nil]
      )
      version = Ruby.version(context)
      assert_equal(2, version.major)
      assert_equal(3, version.minor)
    end
  end
end
