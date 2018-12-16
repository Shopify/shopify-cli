require 'test_helper'

module CLI
  module Kit
    class LoggerTest < MiniTest::Test
      def setup
        super
        @tmp_file = Tempfile.new('log').tap(&:close)
        @logger = CLI::Kit::Logger.new(debug_log_file: @tmp_file.path)
      end

      def test_info
        out, _ = capture_io do
          @logger.info("hello")
        end
        assert_equal "\e[0mhello", out.chomp
        assert_debug_log_entry("hello", "INFO")
      end

      def test_info_without_debug_log
        out, _ = capture_io do
          @logger.info("hello", debug: false)
        end
        assert_equal "\e[0mhello", out.chomp
        assert_empty File.read(@tmp_file.path).chomp
      end

      def test_warn
        out, _ = capture_io do
          @logger.warn("hello")
        end
        assert_equal "\e[0;33mhello\e[0m", out.chomp
        assert_debug_log_entry("hello", "WARN")
      end

      def test_warn_without_debug_log
        out, _ = capture_io do
          @logger.warn("hello", debug: false)
        end
        assert_equal "\e[0;33mhello\e[0m", out.chomp
        assert_empty File.read(@tmp_file.path).chomp
      end

      def test_error
        _, err = capture_io do
          @logger.error("hello")
        end
        assert_equal "\e[0;31mhello\e[0m", err.chomp
        assert_debug_log_entry("hello", "ERROR")
      end

      def test_error_without_debug_log
        _, err = capture_io do
          @logger.error("hello", debug: false)
        end
        assert_equal "\e[0;31mhello\e[0m", err.chomp
        assert_empty File.read(@tmp_file.path).chomp
      end

      def test_fatal
        _, err = capture_io do
          @logger.fatal("hello")
        end
        assert_equal "\e[0;31;1mFatal:\e[0;31m hello\e[0m", err.chomp
        assert_debug_log_entry("hello", "FATAL")
      end

      def test_fatal_without_debug_log
        _, err = capture_io do
          @logger.fatal("hello", debug: false)
        end
        assert_equal "\e[0;31;1mFatal:\e[0;31m hello\e[0m", err.chomp
        assert_empty File.read(@tmp_file.path).chomp
      end

      def test_debug_without_debug_env
        out, err = capture_io do
          @logger.debug("hello")
        end
        assert_empty err.chomp
        assert_empty out.chomp
        assert_debug_log_entry("hello", "DEBUG")
      end

      def test_debug_with_debug_env
        with_env('DEBUG' => '1') do
          out, err = capture_io do
            @logger.debug("hello")
          end
          assert_equal "\e[0mhello", out.chomp
          assert_empty err.chomp
          assert_debug_log_entry("hello", "DEBUG")
        end
      end

      def test_with_thread_id_from_cli_ui
        CLI::UI::StdoutRouter.with_id(on_streams: []) do |id|
          capture_io do
            @logger.debug("hello")
          end
          assert_debug_log_entry("hello", "DEBUG", id)
        end
      end

      def assert_debug_log_entry(msg, level, id = nil)
        timestamp_reg = "\\[\\d{4}-\\d\\d-\\d\\dT\\d\\d:\\d\\d:\\d\\d\\.\\d{6} #\\d+\\]"
        reg = "#{level.chars.first}, #{timestamp_reg}\\s+#{level} -- :"
        reg += " \\[\\d+\\]" if id
        reg += " \\e\\[0m#{msg}"
        assert_match Regexp.new(reg), File.read(@tmp_file.path).chomp
      end
    end
  end
end
