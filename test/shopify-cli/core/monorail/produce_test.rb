require 'test_helper'
require 'logger'
require 'stringio'

module ShopifyCli
  module Core
    module Monorail
      class ProduceTest < MiniTest::Test
        include TestHelpers::Constants

        def setup
          super
          @event = { payload: { timestamp: Time.now.utc.to_s } }
          @logger_io = StringIO.new
          redefine_constant(ShopifyCli, :Logger, ::Logger.new(@logger_io))
          Helpers::Async.stubs(:in_thread).yields
        end

        def test_no_retries_success
          stub_request(:post, Monorail::ENDPOINT_URI)
            .to_return(status: 200)
          Monorail.produce(@event, num_retries: 0)

          log_lines = @logger_io.string.lines
          assert_equal(0, log_lines.size)
        end

        def test_no_retries_failure
          stub_request(:post, Monorail::ENDPOINT_URI)
            .to_return(status: 500)
          Monorail.produce(@event, num_retries: 0)

          log_lines = @logger_io.string.lines
          assert_equal(1, log_lines.size)
          assert_match(/Unexpected status 500/, log_lines.last)
        end

        def test_one_retry_then_success
          stub_request(:post, Monorail::ENDPOINT_URI)
            .to_return(status: 500).then
            .to_return(status: 200)
          Monorail.produce(@event, num_retries: 1)

          log_lines = @logger_io.string.lines
          assert_equal(1, log_lines.size)
          assert_match(/retrying/, log_lines.first)
        end

        def test_one_retry_then_failure
          stub_request(:post, Monorail::ENDPOINT_URI)
            .to_return(status: 500).then
            .to_return(status: 500)
          Monorail.produce(@event, num_retries: 1)

          log_lines = @logger_io.string.lines
          assert_equal(2, log_lines.size)
          assert_match(/retrying/, log_lines.first)
          assert_match(/Unexpected status 500/, log_lines.last)
        end

        def test_three_retries_then_failure
          stub_request(:post, Monorail::ENDPOINT_URI)
            .to_return(status: 500).then
            .to_return(status: 500).then
            .to_return(status: 500).then
            .to_return(status: 500)
          Monorail.produce(@event) # default is three

          log_lines = @logger_io.string.lines
          assert_equal(4, log_lines.size)
          assert_match(/retrying/, log_lines[0])
          assert_match(/retrying/, log_lines[1])
          assert_match(/retrying/, log_lines[2])
          assert_match(/Unexpected status 500/, log_lines.last)
        end
      end
    end
  end
end
