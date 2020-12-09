require 'test_helper'

module ShopifyCli
  module Commands
    class CommandTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:node)
      end

      def test_non_existant
        io = capture_io { assert_raises(ShopifyCli::AbortSilent) { run_cmd('foobar') } }

        assert_match(/foobar.*was not found/, io.join)
      end

      def test_calls_help_with_h_flag
        io = capture_io { run_cmd('create -h') }

        assert_match(CLI::UI.fmt(Create.help), io.join)
      end

      def test_calls_help_with_subcommand_h_flag
        io = capture_io { run_cmd('generate page --help') }

        assert_match(CLI::UI.fmt(Node::Commands::Generate::Page.help), io.join)
      end
    end
  end
end
