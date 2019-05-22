require 'test_helper'

module ShopifyCli
  module Helpers
    class PidFileTest < MiniTest::Test
      def setup
        @pid_file = PidFile.new('web', pid: 1234)
      end

      def test_pid_has_expected_attributes
        assert_equal(1234, @pid_file.pid)
        assert_equal('web', @pid_file.identifier)
        assert_equal(
          File.join(ShopifyCli::TEMP_DIR, 'sv/web.pid'), @pid_file.pid_path
        )
        assert_equal(
          File.join(ShopifyCli::TEMP_DIR, 'sv/web.log'), @pid_file.log_path
        )
      end
    end
  end
end
