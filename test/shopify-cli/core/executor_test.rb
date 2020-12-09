require 'test_helper'

module ShopifyCli
  module Core
    class ExecutorTest < MiniTest::Test
      include TestHelpers::FakeTask

      class FakeCommand < ShopifyCli::Command
        prerequisite_task :fake

        class FakeSubCommand < ShopifyCli::SubCommand
          prerequisite_task :fake

          def call(*)
            @ctx.puts('subcommand!')
          end
        end

        subcommand :FakeSubCommand, 'fakesub'

        options { |parser, flags| parser.on('-v', '--verbose', 'print verbosely') { |v| flags[:verbose] = v } }

        def call(_args, _name)
          options.flags[:verbose] ? @ctx.puts('verbose!') : @ctx.puts('command!')
        end
      end

      def setup
        @log = Tempfile.new
        super
      end

      def test_prerequisite_task
        executor = ShopifyCli::Core::Executor.new(@context, @registry, log_file: @log)
        reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
        reg.add(FakeCommand, :fake)
        @context.expects(:puts).with('success!')
        @context.expects(:puts).with('command!')
        executor.call(FakeCommand, 'fake', [])
      end

      def test_options
        executor = ShopifyCli::Core::Executor.new(@context, @registry, log_file: @log)
        reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
        reg.add(FakeCommand, :fake)
        @context.expects(:puts).with('success!')
        @context.expects(:puts).with('verbose!')
        executor.call(FakeCommand, 'fake', %w[-v])
      end

      def test_subcommand
        executor = ShopifyCli::Core::Executor.new(@context, @registry, log_file: @log)
        reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
        reg.add(FakeCommand, :fake)
        @context.expects(:puts).with('success!')
        @context.expects(:puts).with('subcommand!')
        executor.call(FakeCommand, 'fake', %w[fakesub])
      end
    end
  end
end
