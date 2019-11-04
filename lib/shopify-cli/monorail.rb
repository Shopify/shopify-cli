require 'json'
require 'securerandom'
require 'time'
require 'timeout'
require 'net/http'

module ShopifyCli
  module Monorail
    autoload :Log, 'shopify-cli/monorail/log'

    ENDPOINT_URI = URI.parse('https://monorail-edge.shopifycloud.com/v1/produce')

    class MonorailError < StandardError; end

    class NilWriter
      def write(*args); end
    end

    class << self
      attr_writer :monorail, :events

      def log
        return @monorail if @monorail
        prompt_for_consent
        writable = if enabled? && consented?
          events
        else
          NilWriter.new
        end
        @monorail = ShopifyCli::Monorail::Log.new(writable: writable)
      end

      def send_events
        return unless enabled?
        return unless consented?
        new_events = events.tail(200).select do |line|
          event = JSON.parse(line, symbolize_names: true)
          Time.parse(event[:payload][:timestamp]) > mtime
        end

        new_events.reverse.each do |line|
          event = JSON.parse(line, symbolize_names: true)
          produce(event)
          File.write(ShopifyCli::EVENTS_MTIME, event[:payload][:timestamp])
        end
      end

      def produce(event, num_retries: 3)
        headers = {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Monorail-Edge-Event-Created-At-Ms': Time.parse(event[:payload][:timestamp]).to_i.to_s,
          'X-Monorail-Edge-Event-Sent-At-Ms': Time.now.utc.to_i.to_s,
        }
        do_post(headers, JSON.dump(event), num_retries)
      rescue Exception => e # rubocop:disable Lint/RescueException
        ShopifyCli::Logger.error(name) { "Unexpected error when posting #{event.inspect}: #{e.inspect}" }
      end

      private

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

      def do_post(headers, body, num_retries)
        Helpers::Async.in_thread do
          CLI::Kit::Util.begin do
            Net::HTTP.start(ENDPOINT_URI.host, ENDPOINT_URI.port, use_ssl: ENDPOINT_URI.scheme == 'https') do |http|
              post = Net::HTTP::Post.new(ENDPOINT_URI.request_uri, headers)
              post.body = body
              http.request(post) do |response|
                code = response.code.to_i
                unless code == 200
                  raise(MonorailError, "Unexpected status #{code} from Monorail Edge: #{response.body}")
                end
              end
            end
          end.retry_after(MonorailError, retries: num_retries) do |error|
            ShopifyCli::Logger.warn(name) { "#{error.message}; retrying..." }
          end
        end
      end

      def enabled?
        # we only want to send Monorail events in production or when explicitly developing
        ShopifyCli::Util.system? || ENV['MONORAIL_REAL_EVENTS'] == '1'
      end

      def consented?
        ShopifyCli::Config.get_bool('analytics', 'enabled')
      end

      def events
        @events ||= ShopifyCli::Log.new(ShopifyCli::EVENTS_FILE, mode: 'a+')
      end

      def mtime
        @mtime ||= Time.parse(File.read(Helpers::FS.ensure_file(ShopifyCli::EVENTS_MTIME)))
      rescue ArgumentError
        Time.new(2019)
      end
    end
  end
end
