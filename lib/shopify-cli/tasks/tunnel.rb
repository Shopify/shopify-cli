require 'json'
require 'fileutils'
require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Tunnel < ShopifyCli::Task
      include ShopifyCli::Helpers::OS

      class FetchUrlError < RuntimeError; end
      class NgrokError < RuntimeError; end

      PORT = 8081
      DOWNLOAD_URLS = {
        mac: 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-amd64.zip',
        linux: 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip',
      }
      TIMEOUT = 10

      def call(ctx)
        @ctx = ctx
        start
      end

      def stop(ctx)
        @ctx = ctx
        if running?
          begin
            ShopifyCli::Helpers::ProcessSupervision.stop(:ngrok)
            pid_file = ShopifyCli::Helpers::PidFile.for(:ngrok)
            pid_file&.unlink_log
            @ctx.puts("{{green:x}} ngrok tunnel stopped")
          rescue
            @ctx.error(
              'ngrok tunnel could not be stopped. Try running {{command:killall -9 ngrok}}'
            )
          end
        else
          @ctx.puts("{{green:x}} ngrok tunnel not running")
        end
      end

      def start
        install

        unless running?
          ShopifyCli::Helpers::ProcessSupervision.start(:ngrok, ngrok_command)
        end
        pid_file = ShopifyCli::Helpers::PidFile.for(:ngrok)
        log = fetch_url(pid_file.log_path)
        if log.account
          @ctx.puts("{{v}} ngrok tunnel running at {{underline:#{log.url}}}, with account #{log.account}")
        else
          @ctx.puts("{{v}} ngrok tunnel running at {{underline:#{log.url}}}")
        end
        @ctx.app_metadata = { host: log.url }
        log.url
      end

      def auth(ctx, token)
        install

        ctx.system(File.join(ShopifyCli::ROOT, 'ngrok'), 'authtoken', token)
      end

      def running?
        ShopifyCli::Helpers::ProcessSupervision.running?(:ngrok)
      end

      private

      def install
        return if File.exist?(File.join(ShopifyCli::ROOT, 'ngrok'))
        spinner = CLI::UI::SpinGroup.new
        spinner.add('Installing ngrok...') do
          zip_dest = File.join(ShopifyCli::ROOT, 'ngrok.zip')
          unless File.exist?(zip_dest)
            @ctx.system('curl', '-o', zip_dest, DOWNLOAD_URLS[os], chdir: ShopifyCli::ROOT)
          end
          @ctx.system('unzip', '-u', zip_dest, chdir: ShopifyCli::ROOT)
          @ctx.rm(zip_dest)
        end
        spinner.wait
      end

      def fetch_url(log_path)
        LogParser.new(log_path)
      rescue RuntimeError => e
        stop(@ctx)
        raise e.class, e.message
      end

      def ngrok_command
        "exec #{File.join(ShopifyCli::ROOT, 'ngrok')} http -log=stdout -log-level=debug #{PORT}"
      end

      class LogParser
        attr_reader :url, :account

        def initialize(log_path)
          @log_path = log_path
          counter = 0
          while counter < TIMEOUT
            parse
            return if url
            counter += 1
            sleep(1)
          end

          raise FetchUrlError, "Unable to fetch external url" unless url
        end

        def parse
          @log = File.read(@log_path)
          unless error.empty?
            raise NgrokError, error.first
          end
          parse_account
          parse_url
        end

        def parse_url
          @url, _ = @log.match(/msg="started tunnel".*url=(https:\/\/.+)/)&.captures
        end

        def parse_account
          @account, _ = @log.match(/AccountName:([\w\s]+) SessionDuration/)&.captures
        end

        def error
          @log.scan(/msg="command failed" err="([^"]+)"/).flatten
        end
      end
    end
  end
end
