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
      @ctx.expects(:capture2).with('uname -a').returns(
        ['Darwin hostname.local 18.6.0 Darwin Kernel Version 18.6.0', nil]
      )
      assert(@ctx.mac?)
      assert_equal(:mac, @ctx.os)
      refute(@ctx.linux?)
    end

    def test_linux_matches
      @ctx.expects(:capture2).with('uname -a').returns(
        ['Linux hostname 4.15.0-50-generic #54-Ubuntu SMP', nil]
      )
      assert(@ctx.linux?)
      assert_equal(:linux, @ctx.os)
      refute(@ctx.mac?)
    end

    def test_open_url_formats_command_correctly
      url = 'http://cutekitties.com'
      stubs(:mac?).returns(true)
      @ctx.expects(:system).with("open '#{url}'")
      @ctx.open_url!(url)
    end
  end
end
