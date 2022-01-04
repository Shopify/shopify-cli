# typed: ignore
require "test_helper"

module ShopifyCLI
  class OptionsTest < MiniTest::Test
    def setup
      super
      @block = proc do |parser, flags|
        parser.on("-v", "--verbose", "run verbosely") do |v|
          flags[:verbose] = v
        end
      end
    end

    def test_parses_subcommand_and_flags
      opts = Options.new
      assert_equal ["subc", "foo", "bar"], opts.parse(@block, ["subc", "-v", "foo", "bar"])
      assert opts.flags[:verbose]
    end

    def test_parse_returns_empty_array_when_no_args_provided
      opts = Options.new
      assert_equal [], opts.parse(@block, [])
    end

    def test_parses_help_flag_and_sets_help_attribute
      block = proc {}
      opts = Options.new
      opts.parse(block, ["-h"])
      assert opts.help
    end
  end
end
