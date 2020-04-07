require 'test_helper'

module ShopifyCli
  class ProcessSuperVisionTest < MiniTest::Test
    def teardown
      return unless @process&.alive?
      @process.stop
    end

    def test_pid_has_expected_attributes
      process = ProcessSupervision.new('web', pid: 1234)
      assert_equal(1234, process.pid)
      assert_equal('web', process.identifier)
      assert_equal(
        File.join(ShopifyCli::TEMP_DIR, 'sv/web.pid'), process.pid_path
      )
      assert_equal(
        File.join(ShopifyCli::TEMP_DIR, 'sv/web.log'), process.log_path
      )
    end

    def test_start
      @process = ProcessSupervision.start('example', 'sleep 1')
      assert_process_running(@process.pid)
      assert ProcessSupervision.running?('example')
    end

    def test_alive
      @process = ProcessSupervision.start('example', 'sleep 1')
      assert @process.alive?
      assert @process.stop
      refute @process.alive?
    end

    def test_stop
      spawn_fake_process('example')
      @process = ProcessSupervision.for_ident('example')
      assert_process_running(@process.pid)
      ProcessSupervision.stop('example')
      refute_process_running(@process.pid)
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
      process = ProcessSupervision.new(identifier, pid: pid)
      process.write
    end
  end
end
