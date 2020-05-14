require 'json'
require 'net/http'
require 'time'
require 'rbconfig'

module ShopifyCli
  module Core
    module Monorail
      ENDPOINT_URI = URI.parse('https://monorail-edge.shopifycloud.com/v1/produce')
      INVOCATIONS_SCHEMA = 'app_cli_command/1.0'
      SUCCESS_SENTINEL = '_success'
      MICROSECOND_PRECISION = 6

      class << self
        def log(name, args, &block) # rubocop:disable Lint/UnusedMethodArgument
          prompt_for_consent

          args = args.dup.unshift(name)
          command_with_args = args.join(' ')

          # option to add future logic to capture block result in monorail event
          capture_result = false

          start_time = Time.now.utc
          begin
            block_result = yield
            end_time = Time.now.utc
            send_event(
              schema_id: INVOCATIONS_SCHEMA,
              payload: monorail_payload(
                args: command_with_args,
                duration: (end_time - start_time),
                result: (capture_result ? block_result.to_s : SUCCESS_SENTINEL)
              )
            )
            return block_result
          rescue Exception => e # rubocop:disable Lint/RescueException
            end_time = Time.now.utc
            send_event(
              schema_id: INVOCATIONS_SCHEMA,
              payload: monorail_payload(
                args: command_with_args,
                duration: (end_time - start_time),
                result: e.class.name
              )
            )
            raise
          end
        end

        private

        def enabled?
          # we only want to send Monorail events in production or when explicitly developing
          Context.new.system? || ENV['MONORAIL_REAL_EVENTS'] == '1'
        end

        def consented?
          ShopifyCli::Config.get_bool('analytics', 'enabled')
        end

        def prompt_for_consent
          return unless enabled?
          return if ShopifyCli::Config.get_section('analytics').key?('enabled')
          msg = <<~MSG
            Would you like to enable anonymous usage reporting?
            If you select “Yes”, we’ll collect data about which commands you use and which errors you encounter.
            Sharing this anonymous data helps Shopify improve this tool.
          MSG
          opt = CLI::UI::Prompt.confirm(msg)
          ShopifyCli::Config.set('analytics', 'enabled', opt)
        end

        def monorail_payload(args:, duration:, result:)
          {
            cli_sha: ShopifyCli::Git.sha(dir: ShopifyCli::ROOT),
            uname: RbConfig::CONFIG["host"],
            args: args,
            timestamp: Time.now.utc.iso8601(MICROSECOND_PRECISION),
            duration: duration,
            result: result,
          }
        end

        def ruby_version
          @ruby_version ||= RUBY_VERSION
        end

        def send_event(event)
          return unless enabled?
          return unless consented?

          headers = {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Monorail-Edge-Event-Created-At-Ms': Time.parse(event[:payload][:timestamp]).to_i.to_s,
            'X-Monorail-Edge-Event-Sent-At-Ms': Time.now.utc.to_i.to_s,
          }

          begin
            Net::HTTP.start(
              ENDPOINT_URI.host,
              ENDPOINT_URI.port,
              # timeouts for opening a connection, reading, writing (in seconds)
              open_timeout: 0.2, read_timeout: 0.2, write_timeout: 0.2,
              use_ssl: ENDPOINT_URI.scheme == 'https'
            ) do |http|
              post = Net::HTTP::Post.new(ENDPOINT_URI.request_uri, headers)
              post.body = JSON.dump(event)
              http.request(post)
            end
          rescue
            # silently fail on errors, fire-and-forget approach
          end
        end
      end
    end
  end
end
