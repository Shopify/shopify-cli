require 'json'
require 'tempfile'
require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Tunnel < ShopifyCli::Task
      class FetchUrlError < RuntimeError; end
      class NgrokError < RuntimeError; end

      PORT = 8081
      DOWNLOAD_URLS = {
        mac: 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-amd64.zip',
      }
      TIMEOUT = 5

      def call(ctx)
        @ctx = ctx
        start
      end

      def stop(ctx)
        @ctx = ctx
        if running?
          Process.kill(9, state[:pid])
          FileUtils.rm(pid_file)
          @ctx.puts("{{green:x}} ngrok tunnel stopped")
        else
          @ctx.puts("{{green:x}} ngrok tunnel not running")
        end
      end

      def start
        install

        url = if running?
          state[:url]
        else
          run
        end
        @ctx.puts("{{green:✔︎}} ngrok tunnel running at #{url}")
        url
      end

      def run
        pid = @ctx.spawn(ngrok_command, chdir: ShopifyCli::ROOT)
        Process.detach(pid)
        url = fetch_url
        write_state(pid, url, Time.now)
        url
      end

      private

      def running?
        if File.exist?(pid_file)
          state = read_state
          begin
            Process.kill(0, state[:pid])
            true
          rescue Errno::ESRCH
            false
          rescue Errno::EPERM
            false
          end
        else
          false
        end
      end

      def read_state
        content = JSON.parse(File.open(pid_file).read)
        {
          pid: content['pid'],
          url: content['url'],
          time: content['time'],
        }
      end

      def write_state(pid, url, time)
        File.open(pid_file, 'w') do |f|
          f.write({
            pid: pid,
            url: url,
            time: time,
          }.to_json)
        end
      end

      def install
        return if File.exist?(File.join(ShopifyCli::ROOT, 'ngrok'))
        spinner = CLI::UI::SpinGroup.new
        spinner.add('Installing ngrok...') do
          zip_dest = File.join(ShopifyCli::ROOT, 'ngrok.zip')
          unless File.exist?(zip_dest)
            @ctx.system('curl', '-o', zip_dest, DOWNLOAD_URLS[:mac], chdir: ShopifyCli::ROOT)
          end
          @ctx.system('unzip', '-u', zip_dest, chdir: ShopifyCli::ROOT)
          FileUtils.rm(zip_dest)
        end
        spinner.wait
      end

      def fetch_url
        counter = 0
        while counter < TIMEOUT
          log_content = File.read(log)
          result = log_content.match(/msg="started tunnel".*url=(https:\/\/.+)/)
          return result[1] if result

          counter += 1
          sleep(1)
        end

        error = log_content.scan(/msg="command failed" err="([^"]+)"/).flatten
        unless error.empty?
          stop(@ctx)
          raise NgrokError, error.first
        end

        raise FetchUrlError, "Unable to fetch external url"
      end

      def ngrok_command
        "exec #{File.join(ShopifyCli::ROOT, 'ngrok')} http -log=stdout -log-level=debug #{PORT} > #{log}"
      end

      def log
        @log ||= begin
          fname = File.join(ShopifyCli::ROOT, '.tmp', 'ngrok.log')
          FileUtils.touch(fname)
          File.join(fname)
        end
      end

      def pid_file
        File.join(ShopifyCli::ROOT, '.tmp/ngrok.pid')
      end

      def state
        @state ||= read_state
      end
    end
  end
end
