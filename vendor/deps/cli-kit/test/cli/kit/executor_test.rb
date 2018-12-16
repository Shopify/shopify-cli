require 'test_helper'
require 'tempfile'

module CLI
  module Kit
    class ExecutorTest < MiniTest::Test
      attr_reader :exe
      def setup
        @tf  = Tempfile.create('executor-log').tap(&:close)
        @exe = Executor.new(log_file: @tf.path)
      end

      def teardown
        File.unlink(@tf.path)
      end

      def test_nil_log
        exe = Executor.new(log_file: @tf.path)
        out, err = capture_io do
          CLI::UI::StdoutRouter.with_enabled do
            exe.call(SimpleCommand, 'foo', %w(a b))
          end
        end
        assert_equal(%(foo: ["a", "b"]\n), out)
        assert_empty(err)
      end

      def test_call_with_exception
        SimpleCommand.any_instance.expects(:call).raises(StandardError)
        CLI::UI::StdoutRouter.expects(:with_id).yields("12345")

        exe = Executor.new(log_file: @tf.path)
        out, err = capture_io do
          assert_raises StandardError do
            CLI::UI::StdoutRouter.with_enabled do
              exe.call(SimpleCommand, 'foo', %w(a b))
            end
          end
        end

        assert_equal(<<~EOF, err)
        This command ran with ID: 12345
        Please include this information in any issues/report along with relevant logs
        EOF
        assert_empty(out)
      end

      def test_command_runs
        out, err = capture_io do
          CLI::UI::StdoutRouter.with_enabled do
            exe.call(SimpleCommand, 'foo', %w(a b))
          end
        end
        assert_equal(%(foo: ["a", "b"]\n), out)
        assert_match(
          /\[\d{5}\] foo: \["a", "b"\]\n/,
          File.read(@tf.path)
        )
        assert_empty(err)
      end

      def test_siginfo_handling
        if Signal.list.key?('INFO')
          out, err = capture_io do
            exe.call(->(*) { Process.kill('INFO', Process.pid) }, 'foo', [])
          end
          assert_empty(out)
          lines = err.lines
          assert_equal("SIGINFO:\n", lines.shift)
          assert_is_stack_trace(lines)
        else
          pass 'INFO isnt available on this system, but that is ok'
        end
      end

      def test_sigquit_handling
        @exe.expects(:exit).with(CLI::Kit::EXIT_FAILURE_BUT_NOT_BUG)
        out, err = capture_io do
          exe.call(->(*) { Process.kill('QUIT', Process.pid) }, 'foo', [])
        end
        assert_empty(out)
        lines = err.lines
        assert_equal("SIGQUIT: quit\n", lines.shift)
        assert_is_stack_trace(lines)
      end

      private

      def assert_is_stack_trace(lines)
        assert_in_delta(60, 30, lines.size) # 40 at time of measure, allow 30..90
        lines.each do |line|
          assert_match(%r{/.*:\d+:in .*}, line)
        end
      end

      class SimpleCommand < BaseCommand
        def call(args, name)
          puts("#{name}: #{args.inspect}")
        end
      end
    end
  end
end
