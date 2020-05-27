require 'json'
require 'net/http'
require 'time'
require 'rbconfig'

module ShopifyCli
  module Core
    module Monorail
      ENDPOINT_URI = URI.parse('https://monorail-edge.shopifycloud.com/v1/produce')
      INVOCATIONS_SCHEMA = 'app_cli_command/2.0'

      # Extra hash of data that will be sent in the payload
      @metadata = {}

      class << self
        attr_accessor :metadata

        def log(name, args, &block) # rubocop:disable Lint/UnusedMethodArgument
          prompt_for_consent
          return yield unless enabled? && consented?

          args = args.dup.unshift(name)
          start_time = now_in_milliseconds
          err = nil
          begin
            result = yield
            return result
          rescue Exception => e # rubocop:disable Lint/RescueException
            err = e
            raise
          ensure
            send_event(start_time, args, err&.message)
          end
        end

        private

        def now_in_milliseconds
          (Time.now.utc.to_f * 1000).to_i
        end

        # we only want to send Monorail events in production or when explicitly developing
        def enabled?
          Context.new.system? || ENV['MONORAIL_REAL_EVENTS'] == '1'
        end

        def consented?
          ShopifyCli::Config.get_bool('analytics', 'enabled')
        end

        def prompt_for_consent
          return unless enabled?
          return if ShopifyCli::Config.get_section('analytics').key?('enabled')
          msg = Context.message('core.monorail.consent_prompt')
          opt = CLI::UI::Prompt.confirm(msg)
          ShopifyCli::Config.set('analytics', 'enabled', opt)
        end

        def send_event(start_time, args, err = nil)
          end_time = now_in_milliseconds
          headers = {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Monorail-Edge-Event-Created-At-Ms': start_time.to_s,
            'X-Monorail-Edge-Event-Sent-At-Ms': end_time.to_s,
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
              post.body = JSON.dump(build_payload(start_time, end_time, args, err))
              http.request(post)
            end
          rescue
            # silently fail on errors, fire-and-forget approach
          end
        end

        def build_payload(start_time, end_time, args, err = nil)
          {
            schema_id: INVOCATIONS_SCHEMA,
            payload: {
              project_type: Project.current_project_type.to_s,
              args: args.join(' '),
              time_start: start_time,
              time_end: end_time,
              total_time: end_time - start_time,
              success: err.nil?,
              error_message: err,
              uname: RbConfig::CONFIG["host"],
              cli_sha: ShopifyCli::Git.sha(dir: ShopifyCli::ROOT),
              ruby_version: RUBY_VERSION,
            }.tap do |payload|
              payload[:metadata] = JSON.dump(metadata) unless metadata.empty?

              if Project.has_current?
                project = Project.current
                # payload[:api_client_id] = project.env.api_key
                payload[:partner_id] = project.config['organization_id']
              end
            end,
          }
        end
      end
    end
  end
end
