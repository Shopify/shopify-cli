require "test_helper"

module ShopifyCLI
  module Core
    class ExecutorTest < MiniTest::Test
      include TestHelpers::FakeTask

      class FakeCommand < ShopifyCLI::Command
        prerequisite_task :fake
        prerequisite_task fake_with_args: [:foo, :bar]

        class FakeSubCommand < ShopifyCLI::Command::SubCommand
          prerequisite_task :fake
          prerequisite_task fake_with_args: [:sub, :command]

          def call(*)
            @ctx.puts("subcommand!")
          end
        end

        subcommand :FakeSubCommand, "fakesub"

        options do |parser, flags|
          parser.on("-v", "--verbose", "print verbosely") do |v|
            flags[:verbose] = v
          end
        end

        def call(_args, _name)
          if options.flags[:verbose]
            @ctx.puts("verbose!")
          else
            @ctx.puts("command!")
          end
        end
      end

      def setup
        @log = Tempfile.new
        super
      end

      def test_prerequisite_task
        executor = ShopifyCLI::Core::Executor.new(@context, @registry, log_file: @log)
        reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
        reg.add(FakeCommand, :fake)
        @context.expects(:puts).with("success!")
        @context.expects(:puts).with("success with args foobar!")
        @context.expects(:puts).with("command!")
        executor.call(FakeCommand, "fake", [])
      end

      def test_options
        executor = ShopifyCLI::Core::Executor.new(@context, @registry, log_file: @log)
        reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
        reg.add(FakeCommand, :fake)
        @context.expects(:puts).with("success!")
        @context.expects(:puts).with("success with args foobar!")
        @context.expects(:puts).with("verbose!")
        executor.call(FakeCommand, "fake", ["-v"])
      end

      def test_subcommand
        executor = ShopifyCLI::Core::Executor.new(@context, @registry, log_file: @log)
        reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
        reg.add(FakeCommand, :fake)
        @context.expects(:puts).with("success!")
        @context.expects(:puts).with("success with args subcommand!")
        @context.expects(:puts).with("subcommand!")
        executor.call(FakeCommand, "fake", ["fakesub"])
      end
    end
  end
end
