require 'test_helper'

module ShopifyCli
  class OptionsTest < MiniTest::Test
    def test_parses_subcommand_and_flags
      block = proc do |parser, flags|
        parser.on('-v', '--verbose', 'run verbosely') do |v|
          flags[:verbose] = v
        end
      end
      opts = Options.new
      assert_equal ['subc', 'foo', 'bar'], opts.parse(block, ['subc', '-v', 'foo', 'bar'])
      assert_equal true, opts.flags[:verbose]
    end

    def test_parse_returns_empty_array_when_no_args_provided
      block = proc do |parser, flags|
        parser.on('-v', '--verbose', 'run verbosely') do |v|
          flags[:verbose] = v
        end
      end
      opts = Options.new
      assert_equal [], opts.parse(block, [])
    end
  end
end
