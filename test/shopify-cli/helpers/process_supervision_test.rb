require 'test_helper'

module ShopifyCli
  module Helpers
    class ProcessSuperVisionTest < MiniTest::Test
      def teardown
        return unless @pid_file

        begin
          Process.kill("TERM", @pid_file.pid)
        rescue Errno::EPERM
          # Happens with start_fg due to exec-ing the forked process
        rescue Errno::ESRCH
          # It's okay if it's not running anymore
        end

        @pid_file.unlink
        @pid_file.unlink_log
      end

      def test_start
        ProcessSupervision.start('example', 'sleep 1')
        @pid_file = PidFile.for('example')

        assert_process_running(@pid_file.pid)

        assert ProcessSupervision.running?('example')
      end

      def test_stop
        spawn_fake_process('example')
        @pid_file = PidFile.for('example')
        assert_process_running(@pid_file.pid)

        ProcessSupervision.stop('example')

        refute_process_running(@pid_file.pid)

        refute ProcessSupervision.running?('example')
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

      def spawn_fake_process(identifier)
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

        PidFile.new(identifier, pid: pid).tap do |pid_file|
          PidFile.write(pid_file)
        end
      end
    end
  end
end
