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
            @ctx.puts("{{red:x}} ngrok tunnel could not be stopped. Try running {{command:killall -9 ngrok}}")
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
        url = fetch_url(pid_file.log_path)
        @ctx.puts("{{green:✔︎}} ngrok tunnel running at {{underline: #{url}}}")
        @ctx.app_metadata = { host: url }
        url
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
          FileUtils.rm(zip_dest)
        end
        spinner.wait
      end

      def fetch_url(log_path)
        counter = 0
        while counter < TIMEOUT
          log_content = File.read(log_path)
          result = log_content.match(/msg="started tunnel".*url=(https:\/\/.+)/)
          return result[1] if result

          counter += 1
          sleep(1)

          error = log_content.scan(/msg="command failed" err="([^"]+)"/).flatten
          unless error.empty?
            stop(@ctx)
            raise NgrokError, error.first
          end
        end

        raise FetchUrlError, "Unable to fetch external url"
      end

      def ngrok_command
        "exec #{File.join(ShopifyCli::ROOT, 'ngrok')} http -log=stdout -log-level=debug #{PORT}"
      end
    end
  end
end
