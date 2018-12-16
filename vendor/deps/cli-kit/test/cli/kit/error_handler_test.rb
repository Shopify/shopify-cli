require 'test_helper'
require 'tempfile'

module CLI
  module Kit
    class ErrorHandlerTest < MiniTest::Test
      def setup
        @rep = Object.new
        @tf  = Tempfile.create('executor-log').tap(&:close)
        @eh = ErrorHandler.new(log_file: @tf.path, exception_reporter: @rep)
        class << @eh
          attr_reader :exit_handler
          # Prevent `install!` from actually installing the hook.
          def at_exit(&block)
            @exit_handler = block
          end
        end
      end

      def teardown
        File.unlink(@tf.path)
      end

      def test_success
        run_test(
          expect_code:   CLI::Kit::EXIT_SUCCESS,
          expect_out:    "neato\n",
          expect_err:    "",
          expect_report: false,
        ) do
          puts 'neato'
        end
      end

      def test_abort_silent
        run_test(
          expect_code:   CLI::Kit::EXIT_FAILURE_BUT_NOT_BUG,
          expect_out:    "",
          expect_err:    "",
          expect_report: false,
        ) do
          raise(CLI::Kit::AbortSilent)
        end
      end

      def test_abort
        run_test(
          expect_code:   CLI::Kit::EXIT_FAILURE_BUT_NOT_BUG,
          expect_out:    "",
          expect_err:    /foo/,
          expect_report: false,
        ) do
          raise(CLI::Kit::Abort, 'foo')
        end
      end

      def test_bug_silent
        File.write(@tf.path, 'words')
        run_test(
          expect_code:   CLI::Kit::EXIT_FAILURE_BUT_NOT_BUG,
          expect_out:    "",
          expect_err:    "",
          expect_report: [is_a(CLI::Kit::BugSilent), 'words'],
        ) do
          raise(CLI::Kit::BugSilent)
        end
      end

      def test_bug
        run_test(
          expect_code:   CLI::Kit::EXIT_FAILURE_BUT_NOT_BUG,
          expect_out:    "",
          expect_err:    /foo/,
          expect_report: [is_a(CLI::Kit::Bug), ''],
        ) do
          raise(CLI::Kit::Bug, 'foo')
        end
      end

      def test_interrupt
        run_test(
          expect_code:   CLI::Kit::EXIT_FAILURE_BUT_NOT_BUG,
          expect_out:    "",
          expect_err:    /Interrupt/,
          expect_report: false,
        ) do
          raise(Interrupt)
        end
      end

      def test_unhandled
        run_test(
          expect_code:   :unhandled,
          expect_out:    "",
          expect_err:    "",
          expect_report: [is_a(RuntimeError), ''],
        ) do
          raise('wups')
        end
      end

      # the rest of these are hard because they kind of rely on the handler
      # actually running in at_exit.

      def test_non_bug_signal
        # e.g. SIGTERM
        skip
      end

      def test_bug_signal
        # e.g. SIGSEGV
        skip
      end

      def test_exit_0
        skip
      end

      def test_exit_30
        skip
      end

      def test_exit_1
        skip
      end

      private

      def with_handler
        code = nil
        out, err = capture_io do
          begin
            code = @eh.call { yield }
          rescue => e
            # This is cheating, but it's the easiest way I could think of to
            # work around not wanting to actually have to call an at_exit
            # handler with $ERROR_INFO here.
            @eh.instance_variable_set(:@exception, e)
            code = :unhandled
          ensure
            @eh.exit_handler.call
          end
        end
        [out, err, code]
      end

      def run_test(expect_code:, expect_out:, expect_err:, expect_report:)
        if expect_report
          @rep.expects(:report).once.with(*expect_report)
        else
          @rep.expects(:report).never
        end
        out, err, code = with_handler do
          yield
        end
        assert_equal(expect_out, out)
        if expect_err.is_a?(Regexp)
          assert_match(expect_err, err)
        else
          assert_equal(expect_err, err)
        end
        assert_equal(expect_code, code)
      end
    end
  end
end
