require 'test_helper'

module CLI
  module Kit
    class CommandRegistryTest < MiniTest::Test
      attr_reader :reg, :ctx_reg
      def setup
        @reg = CommandRegistry.new(default: 'dflt', contextual_resolver: nil)
        @ctx_reg = CommandRegistry.new(default: 'dflt', contextual_resolver: ContextualResolver)
      end

      module ContextualResolver
        CommandClass = Class.new

        def self.command_names
          %w(ctx-a ctx-b)
        end

        def self.aliases
          { 'a' => 'ctx-a' }
        end

        def self.command_class(_name)
          CommandClass
        end
      end

      def test_default
        assert_lookup(reg, nil, 'dflt', nil)
        assert_lookup(reg, nil, 'dflt', 'dflt')

        cmd = CLI::Kit::BaseCommand
        reg.add(cmd, 'dflt')
        assert_lookup(reg, cmd, 'dflt', nil)
        assert_lookup(reg, cmd, 'dflt', 'dflt')
      end

      def test_nonexistent
        assert_lookup(reg, nil, 'nope', 'nope')
      end

      def test_lazy_evaluation
        cmd = ->() { CLI::Kit::BaseCommand }
        reg.add(cmd, 'cmd')
        assert_lookup(reg, CLI::Kit::BaseCommand, 'cmd', 'cmd')
      end

      def test_alias
        reg.add_alias('a', 'abc')
        assert_lookup(reg, nil, 'abc', 'a')

        cmd = CLI::Kit::BaseCommand
        reg.add(cmd, 'abc')
        assert_lookup(reg, cmd, 'abc', 'a')
      end

      def test_exist?
        reg.add_alias('a', 'abc')
        reg.add_alias('x', 'xyz')
        cmd = CLI::Kit::BaseCommand
        reg.add(cmd, 'abc')

        assert reg.exist?('abc')
        assert reg.exist?('a')
        refute reg.exist?('xyz')
        refute reg.exist?('x')
      end

      def test_command_names
        reg.add(42, 'abc')
        reg.add(42, 'xyz')
        assert_equal(%w(abc xyz), reg.command_names.sort)
      end

      def test_commands_and_resolved_commands
        block = ->() { 42 }
        reg.add(block, 'abc')
        assert_equal({ 'abc' => block }, reg.commands)
        assert_equal({ 'abc' => 42 }, reg.resolved_commands)
      end

      def test_aliases
        reg.add_alias('a', 'abc')
        assert_equal({ 'a' => 'abc' }, reg.aliases)
      end

      def test_contextual_resolution
        ctx_reg.add(nil, 'asdf')
        ctx_reg.add_alias('neato', 'ctx-a')
        # NOTE: even though ctx_reg has an alias, it's not surfaced here.
        assert_equal({ 'neato' => 'ctx-a' }, ctx_reg.aliases)
        # ...but the alias does resolve.
        cclass = ContextualResolver::CommandClass
        assert_lookup(ctx_reg, cclass, 'ctx-a', 'a')
        assert_lookup(ctx_reg, cclass, 'ctx-a', 'ctx-a')
        assert_lookup(ctx_reg, cclass, 'ctx-a', 'neato')
      end

      private

      def assert_lookup(reg, a, b, c)
        assert_equal([a, b], reg.lookup_command(c))
      end
    end
  end
end
