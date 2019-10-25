require 'test_helper'

module ShopifyCli
  module Helpers
    class OSTest < MiniTest::Test
      include OS
      include TestHelpers::Context

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
        expect_open('python', url)
        expect_open('rundll32', url)
        expect_open('xdg-open', url)
        expect_open('open', url)
      end

      def expect_open(wanted_bin, url)
        OPEN_COMMANDS.each do |bin, cmd|
          if bin == wanted_bin
            File.expects(:executable?).with(bin).returns(true)
            @context.expects(:system).with(cmd, "'#{url}'")
          else
            File.stubs(:executable?).with(bin).returns(false)
          end
        end
        open_url!(@context, url)
      end
    end
  end
end
