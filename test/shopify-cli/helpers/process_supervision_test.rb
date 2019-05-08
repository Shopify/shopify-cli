require 'test_helper'

module ShopifyCli
  module Helpers
    class ProcessSuperVisionTest < MiniTest::Test
      def teardown
        Process.kill("TERM", @pid)
      rescue Errno::EPERM
        # Happens with start_fg due to exec-ing the forked process
      rescue Errno::ESRCH
        # It's okay if it's not running anymore
      end

      def test_start
        @pid = ProcessSupervision.start("sleep 1")

        assert_process_running(@pid)

        assert ProcessSupervision.running?(@pid)
      end

      def test_stop
        @pid = spawn_fake_process("should_stop_me")
        assert_process_running(@pid)

        ProcessSupervision.stop(@pid)

        refute_process_running(@pid)

        refute ProcessSupervision.running?(@pid)
      end

      private

      def assert_process_running(pid)
        if process_running?(pid)
          pass
        else
          flunk("expected #{pid} to be running")
        end
      end

      def refute_process_running(pid)
        if process_running?(pid)
          flunk("expected #{pid} to not be running")
        else
          pass
        end
      end

      def process_running?(pid)
        Process.getpgid(pid)
        true
      rescue Errno::ESRCH
        false
      end

      def spawn_fake_process(name)
        reader, writer = IO.pipe

        pid = fork do
          Process.setproctitle(name)
          Process.setpgrp

          writer.close
          reader.close

          loop do
            sleep 1
          end
        end

        # Allow a TERMed child to be cleaned up while we're still running
        Process.detach(pid)

        # Sync ourselves with the state of the forked process such that setpgrp has been called
        # before we continue on in the test
        writer.close
        reader.read

        pid
      end
    end
  end
end
