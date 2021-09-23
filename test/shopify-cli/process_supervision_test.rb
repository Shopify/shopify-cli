require "test_helper"

module ShopifyCLI
  class ProcessSuperVisionTest < MiniTest::Test
    def test_pid_has_expected_attributes
      process = ProcessSupervision.new("web", pid: 1234)
      assert_equal(1234, process.pid)
      assert_equal("web", process.identifier)
      assert_equal(
        File.join(ShopifyCLI.cache_dir, "sv/web.pid"), process.pid_path
      )
      assert_equal(
        File.join(ShopifyCLI.cache_dir, "sv/web.log"), process.log_path
      )
    end

    def test_start
      process = start
      assert process.alive?
      assert ProcessSupervision.running?("example")
      process.stop
    end

    def test_alive
      process = start
      assert process.alive?
      assert process.stop
      refute process.alive?
    end

    def test_stop
      process = start
      assert process.alive?
      ProcessSupervision.stop("example")
      refute process.alive?
      refute ProcessSupervision.running?("example")
    end

    private

    def start
      process = ProcessSupervision.start("example", "sleep 1")
      Process.detach(process.pid)
      process
    end
  end
end
