require 'test_helper'

module ShopifyCli
  class ExecutorTest < MiniTest::Test
    include TestHelpers::Context
    include TestHelpers::FakeTask

    class FakeCommand < ShopifyCli::Command
      prerequisite_task :fake

      class FakeSubCommand < ShopifyCli::Command
        def call(*)
          @ctx.puts('subcommand!')
        end
      end

      subcommand :FakeSubCommand, 'fakesub'

      options do |parser, flags|
        parser.on('-v', '--verbose', 'print verbosely') do |v|
          flags[:verbose] = v
        end
      end

      def call(_args, _name)
        if options.flags[:verbose]
          @ctx.puts('verbose!')
        else
          @ctx.puts('command!')
        end
      end
    end

    def setup
      @log = Tempfile.new
      super
    end

    def test_prerequisite_task
      executor = ShopifyCli::Executor.new(@context, @registry, log_file: @log)
      reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
      reg.add(FakeCommand, :fake)
      @context.expects(:puts).with('success!')
      @context.expects(:puts).with('command!')
      executor.call(FakeCommand, 'fake', [])
    end

    def test_options
      executor = ShopifyCli::Executor.new(@context, @registry, log_file: @log)
      reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
      reg.add(FakeCommand, :fake)
      @context.expects(:puts).with('success!')
      @context.expects(:puts).with('verbose!')
      executor.call(FakeCommand, 'fake', ['-v'])
    end

    def test_subcommand
      executor = ShopifyCli::Executor.new(@context, @registry, log_file: @log)
      reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
      reg.add(FakeCommand, :fake)
      @context.expects(:puts).with('success!')
      @context.expects(:puts).with('subcommand!')
      executor.call(FakeCommand, 'fake', ['fakesub'])
    end
  end
end
