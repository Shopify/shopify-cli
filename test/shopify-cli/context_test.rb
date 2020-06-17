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

    def test_mac_matches
      @ctx.expects(:uname).returns('x86_64-apple-darwin19.3.0').times(3)
      assert(@ctx.mac?)
      assert_equal(:mac, @ctx.os)
      refute(@ctx.linux?)
    end

    def test_linux_matches
      @ctx.expects(:uname).returns('x86_64-pc-linux-gnu').times(3)
      assert(@ctx.linux?)
      assert_equal(:linux, @ctx.os)
      refute(@ctx.mac?)
    end

    def test_open_url_outputs_url_to_open
      url = 'http://cutekitties.com'
      @ctx.stubs(:mac?).returns(true)
      @ctx.expects(:puts).with(@context.message('core.context.open_url', url))
      @ctx.open_url!(url)
    end
  end
end
