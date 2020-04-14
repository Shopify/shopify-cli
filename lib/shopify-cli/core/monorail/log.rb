require 'json'
require 'securerandom'
require 'time'
require 'timeout'

module ShopifyCli
  module Core
    module Monorail
      class Log
        INVOCATIONS_SCHEMA = 'app_cli_command/1.0'

        SUCCESS_SENTINEL = '_success'

        MICROSECOND_PRECISION = 6

        def initialize(writable:)
          @writable = writable
          @detail_ids = [] # stack of detail ids used to keep track of nested calls
        end

        def invocation(name, args, &block)
          args = args.dup.unshift(name)
          payload = {
            cli_sha: ShopifyCli::Git.sha(dir: ShopifyCli::ROOT),
            uname: uname,
            args: args.join(' '),
          }

          event(schema: INVOCATIONS_SCHEMA, payload: payload, &block)
        end

        private

        def uname
          @uname ||= %x{uname -a}
        end

        def event(schema:, payload:, capture_result: false)
          start_time = Time.now.utc
          send_event(schema, payload.merge(
            timestamp: start_time.iso8601(MICROSECOND_PRECISION),
          ))
          return unless block_given?
          begin
            ret = yield
            end_time = Time.now.utc
            send_event(schema, payload.merge(
              timestamp: end_time.iso8601(MICROSECOND_PRECISION),
              duration: ((end_time - start_time) * 1_000_000).to_i,
              result: capture_result ? ret.to_s : SUCCESS_SENTINEL,
            ))
            return ret
          rescue Exception => e # rubocop:disable Lint/RescueException
            end_time = Time.now.utc
            send_event(schema, payload.merge(
              timestamp: end_time.iso8601(MICROSECOND_PRECISION),
              duration: ((end_time - start_time) * 1_000_000).to_i,
              result: e.class.name,
            ))
            raise
          end
        end

        def send_event(schema, payload)
          return if @circuit_broken
          event = {
            schema_id: schema,
            payload: payload,
          }
          Timeout.timeout(0.5) do
            @writable.write("#{event.to_json}\n")
          end
        rescue Timeout::Error
          @circuit_broken = true
        end
      end
    end
  end
end
