require 'test_helper'

module CLI
  module Kit
    class ResolverTest < MiniTest::Test
      attr_reader :reg, :res
      def setup
        @reg = CommandRegistry.new(default: 'help', contextual_resolver: nil)
        @res = Resolver.new(tool_name: 'tool', command_registry: reg)
      end

      def test_resolver_match
        reg.add(CLI::Kit::BaseCommand, 'foo')
        reg.add_alias('f', 'foo')

        cmd, resolved_name, args = nil
        out, err = capture_io do
          cmd, resolved_name, args = res.call(%w(f a b))
        end

        assert_empty(out)
        assert_empty(err)

        assert_equal(CLI::Kit::BaseCommand, cmd)
        assert_equal('foo', resolved_name)
        assert_equal(%w(a b), args)
      end

      def test_resolver_no_match
        _, err = capture_io do
          assert_raises(CLI::Kit::AbortSilent) do
            res.call(['foo'])
          end
        end
        assert_match(/tool foo.* was not found/, err)
      end

      def test_resolver_suggest
        reg.add(32, 'floo')
        reg.add(32, 'fool')
        reg.add(32, 'bar')

        out, err = capture_io do
          assert_raises(CLI::Kit::AbortSilent) do
            res.call(['foo'])
          end
        end

        assert_equal(4, out.lines.length)
        assert_equal(3, err.lines.length)

        command_not_found, _, did_you_mean, _ = out.lines
        tool_not_found, sugg1, sugg2 = err.lines

        assert_match(/tool foo.* was not found/, tool_not_found)
        assert_match(/tool fool/, sugg1)
        assert_match(/tool floo/, sugg2)

        assert_match(/Command not found/, command_not_found)
        assert_match(/Did you mean/, did_you_mean)
      end

      def test_resolver_threshold
        reg.add(32, 'foooooooooooo')

        out, err = capture_io do
          assert_raises(CLI::Kit::AbortSilent) do
            res.call(['foo'])
          end
        end

        assert_equal(2, out.lines.length)
        assert_equal(1, err.lines.length)

        command_not_found, _, = out.lines
        tool_not_found, = err.lines

        assert_match(/tool foo.* was not found/, tool_not_found)

        assert_match(/Command not found/, command_not_found)
      end
    end
  end
end
