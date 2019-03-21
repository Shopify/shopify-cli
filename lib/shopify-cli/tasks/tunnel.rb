require 'json'
require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Tunnel < ShopifyCli::Task
      PORT = 8081
      DOWNLOAD_URLS = {
        mac: 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-amd64.zip',
      }

      class << self
        def start
          task = new
          task.start
        end

        def stop
          task = new
          task.stop
        end
      end

      def stop
        if running?
          Process.kill(9, state[:pid])
          File.rm(pid_file)
        end
      end

      def start
        ensure_binary

        if running?
          state[:url]
        else
          run
        end
      end

      def restart

      end

      def run
        pid = Kernel.spawn("exec ngrok http " + ngrok_params)
        Process.detach(pid)
        fetch_url
      end

      private

      def running?
        if File.exist?(pid_file)
          state = read_state
          begin
            Process.kill(0, state['pid'])
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

      def pid_file
        File.join(ShopifyCli::ROOT, '.tmp/ngrok.pid')
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

      def ensure_binary
        unless File.exist?(File.join(ShopifyCli::ROOT, 'ngrok'))
          install
        end
      end

      def install
        puts "Installing ngrok"
        zip_dest = File.join(ShopifyCli::ROOT, 'ngrok.zip')
        CLI::Kit::System.system('curl', '-o', zip_dest, DOWNLOAD_URLS[:mac])
        CLI::Kit::System.system('unzip', zip_dest)
        FileUtils.rm(zip_dest)
      end

      def fetch_url
        log_content = log.read
        result = log_content.scan(/URL:(.+)\sProto:(http|https)\s/)
        unless result.empty?
          result = Hash[*result.flatten].invert
          url = result['https']
          return url if url
        end

        error = log_content.scan(/msg="command failed" err="([^"]+)"/).flatten
        unless error.empty?
          stop
          raise Ngrok::Error, error.first
        end

        raise FetchUrlError, "Unable to fetch external url"
      end

      def ngrok_params
        "-log=stdout -log-level=debug #{PORT} > #{log.to_path}"
      end

      def log
        @log ||= Tempfile.new('ngrok')
      end

      def state
        @state ||= read_state
      end
    end
  end
end
