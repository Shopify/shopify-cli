# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  class ContextTest < MiniTest::Test
    include TestHelpers::FakeFS

    def setup
      super
      @ctx = Context.new
    end

    def test_write_writes_to_file_in_project
      @ctx.root = Dir.mktmpdir
      @ctx.write('.env', 'foobar')
      assert File.exist?(File.join(@ctx.root, '.env'))
    end
  end
end
