require 'test_helper'

module ShopifyCli
  module Core
    class FinalizeTest < MiniTest::Test
      def test_deliver_returns_early_if_no_values_set
        IO.expects(:new).never
        assert_nil(Finalize.deliver!)
      end

      def test_deliver_puts_request_cd_if_provided
        mock_io = mock
        mock_io.expects(:puts).with("cd:path/to/cd")
        IO.expects(:new).returns(mock_io)

        Finalize.request_cd('path/to/cd')
        assert_nil(Finalize.deliver!)
      end

      def test_deliver_puts_reload_shopify_from_if_provided
        mock_io = mock
        mock_io.expects(:puts).with("reload_shopify_cli_from:path/to/reload")
        IO.expects(:new).returns(mock_io)

        Finalize.reload_shopify_from('path/to/reload')
        assert_nil(Finalize.deliver!)
      end

      def test_deliver_puts_set_env_values_if_provided
        mock_io = mock
        mock_io.expects(:puts).with("cd:path/to/cd\nreload_shopify_cli_from:path/to/reload\nsetenv:testkey=testvalue")
        IO.expects(:new).returns(mock_io)

        Finalize.setenv('testkey', 'testvalue')
        Finalize.request_cd('path/to/cd')
        Finalize.reload_shopify_from('path/to/reload')
        assert_nil(Finalize.deliver!)
      end

      def test_deliver_puts_error_if_io_error
        IO.expects(:new).raises(IOError.new)

        Finalize.request_cd('path/to/cd')
        output = capture_io do
          Finalize.deliver!
        end
        assert output[1].include?("Not running with shell integration. Finalizers: cd:path/to/cd")
      end

      def test_deliver_raises_argument_error_if_io_not_found
        IO.expects(:new).raises(ArgumentError.new)
        IO.any_instance.stubs(:closed?).returns(true)

        Finalize.request_cd('path/to/cd')
        assert_raises ArgumentError do
          Finalize.deliver!
        end
      end

      def test_deliver_raises_shopifycli_bug_if_io_found_but_used
        IO.expects(:new).raises(ArgumentError.new)
        IO.any_instance.stubs(:closed?).returns(false)
        IO.any_instance.stubs(:fileno).returns(9).twice
        IO.any_instance.expects(:stat).returns(mock(ftype: 'testtype'))

        Finalize.request_cd('path/to/cd')
        error = assert_raises ShopifyCli::Bug do
          Finalize.deliver!
        end
        assert_equal "File descriptor 9, of type testtype, is not available.", error.message
      end
    end
  end
end
