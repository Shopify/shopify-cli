require 'test_helper'

module ShopifyCli
  module Helpers
    class OSTest < MiniTest::Test
      include OS

      def test_mac_matches
        CLI::Kit::System.expects(:capture2).with('uname -a').returns(
          ['Darwin hostname.local 18.6.0 Darwin Kernel Version 18.6.0', nil]
        )
        assert(mac?)
        assert_equal(:mac, os)
        refute(linux?)
      end

      def test_linux_matches
        CLI::Kit::System.expects(:capture2).with('uname -a').returns(
          ['Linux hostname 4.15.0-50-generic #54-Ubuntu SMP', nil]
        )
        assert(linux?)
        assert_equal(:linux, os)
        refute(mac?)
      end

      def test_open_url_formats_command_correctly
        url = 'http://cutekitties.com'
        stubs(:mac?).returns(true)
        @context.expects(:system).with("open '#{url}'")
        open_url!(@context, url)
      end
    end
  end
end
