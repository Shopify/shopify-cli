require 'test_helper'

module CLI
  module Kit
    include CLI::Kit::Support::TestHelper

    class SystemTest < MiniTest::Test
      def test_split_partial_characters_doesnt_split_single_byte_characters
        str = "ルビー is cool"

        assert_equal [str, ''], System.split_partial_characters(str)
      end

      def test_split_partial_characters_splits_partial_characters_with_multiple_bytes
        str = "ルビー".byteslice(0...-1) # => "ルビ\xE3\x83"

        data, trailing = System.split_partial_characters(str)

        assert_equal "ルビ", data
        assert_equal str, data + trailing
      end

      def test_split_partial_characters_splits_partial_characters_with_a_single_byte
        str = "ルビー".byteslice(0...-2) # => "ルビ\xE3"

        data, trailing = System.split_partial_characters(str)

        assert_equal "ルビ", data
        assert_equal str, data + trailing
      end

      def test_split_partial_characters_gives_up_without_error_for_bad_utf8
        str = "Hello\x83\x83\x83\x83\x83\x83\x83\x83"

        assert_equal [str, ''], System.split_partial_characters(str)
      end

      def test_system_finds_system_ruby_instead_of_local_script
        CLI::Kit::System.fake("ruby", "-e", "puts 'system ruby'", allow: true)

        with_script_in_tmpdir("ruby") do |tmpdir|
          Dir.chdir(tmpdir) do
            out, stat = System.capture2("ruby", "-e", "puts 'system ruby'", env: ENV)

            assert stat, message: "expected command to successfully run"
            assert_equal "system ruby", out.chomp
          end
        end
      end

      def test_system_finds_ruby_script_with_path_modifications
        CLI::Kit::System.fake("ruby", "-e", "puts 'system ruby'", allow: true)

        with_script_in_tmpdir("ruby") do |tmpdir|
          with_env("PATH" => "#{tmpdir}:#{ENV['PATH']}") do
            out, stat = System.capture2("ruby", "-e", "puts 'system ruby'", env: ENV)

            assert stat, message: "expected command to successfully run"
            assert_equal "from script", out.chomp
          end
        end
      end

      private

      def with_script_in_tmpdir(script_name)
        Dir.mktmpdir do |tmpdir|
          File.open(File.join(tmpdir, script_name), "w", 0755) do |f|
            f.write("#!/bin/sh\n")
            f.write("echo from script\n")
          end
          yield tmpdir
        end
      end
    end
  end
end
