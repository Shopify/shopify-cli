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
      opts.parse(block, ['subc', '-v'])
      assert_equal true, opts.flags[:verbose]
    end
  end
end
