require 'test_helper'

module ShopfyCli
  module Core
    module Monorail
      class LogInvocationTest < MiniTest::Test
        def setup
          super
          @result, @events = with_monorail_log do |monorail_log|
            monorail_log.invocation('test', %w(arg argtwo)) { 'This is the result' }
          end
        end

        def test_invocation_returns_the_result
          assert_equal('This is the result', @result)
        end

        def test_successful_invocation_generates_two_events
          assert_equal(2, @events.size)
        end

        def test_invocation_has_no_duration_or_result
          invocation, _ = @events

          assert_nil(invocation[:payload][:result])
          assert_nil(invocation[:payload][:duration])
        end

        def test_invocation_result_has_duration_and_result
          _, invocation_result = @events

          assert_equal('_success', invocation_result[:payload][:result])
          refute_nil(invocation_result[:payload][:duration])
        end

        def test_expected_values
          @events.each do |event|
            assert_equal('app_cli_command/1.0', event[:schema_id])
            assert_equal('test arg argtwo', event[:payload][:args])
          end
        end

        def test_all_events_have_timestamps
          @events.each do |event|
            refute_nil(event[:payload][:timestamp])
          end
        end

        protected

        def with_monorail_log
          file = Tempfile.open('monorail_log')
          monorail_log = ShopifyCli::Core::Monorail::Log.new(writable: file)
          result = yield monorail_log
          file.rewind
          events = file.readlines.map { |l| JSON.parse(l, symbolize_names: true) }
          [result, events]
        end
      end
    end
  end
end
