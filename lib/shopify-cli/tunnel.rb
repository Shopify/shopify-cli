require 'json'
require 'fileutils'
require 'shopify_cli'
require 'forwardable'

module ShopifyCli
  ##
  # Wraps around ngrok functionality to allow you to spawn a ngrok proccess in the
  # background and stop the process when you need to. It also allows control over
  # the ngrok process between application runs.
  class Tunnel
    extend SingleForwardable

    def_delegators :new, :start, :stop, :auth, :stats, :urls

    class FetchUrlError < RuntimeError; end
    class NgrokError < RuntimeError; end

    PORT = 8081 # port that ngrok will bind to
    # mapping for supported operating systems for where to download ngrok from.
    DOWNLOAD_URLS = {
      mac: 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-amd64.zip',
      linux: 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip',
      windows: 'https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip',
    }

    NGROK_TUNNELS_URI = URI.parse('http://localhost:4040/api/tunnels')
    TUNNELS_FIELD = 'tunnels'
    PUBLIC_URL_FIELD = 'public_url'

    ##
    # will find and stop a running tunnel process. It will also output if the
    # operation was successful or not
    #
    # #### Paramters
    #
    # * `ctx` - running context from your command
    #
    def stop(ctx)
      if ShopifyCli::ProcessSupervision.running?(:ngrok)
        if ShopifyCli::ProcessSupervision.stop(:ngrok)
          ctx.puts(ctx.message('core.tunnel.stopped'))
        else
          ctx.abort(ctx.message('core.tunnel.error.stop'))
        end
      else
        ctx.puts(ctx.message('core.tunnel.not_running'))
      end
    end

    ##
    # start will start a running ngrok process running in the background. It will
    # also output the success of this operation
    #
    # #### Paramters
    #
    # * `ctx` - running context from your command
    # * `port` - port to use to open the ngrok tunnel
    #
    # #### Returns
    #
    # * `url` - the url that the tunnel is now bound to and available to the public
    #
    def start(ctx, port: PORT)
      install(ctx)
      process = ShopifyCli::ProcessSupervision.start(:ngrok, ngrok_command(port))
      log = fetch_url(ctx, process.log_path)
      if log.account
        ctx.puts(ctx.message('core.tunnel.start_with_account', log.url, log.account))
      else
        ctx.puts(ctx.message('core.tunnel.start', log.url))
      end
      log.url
    end

    ##
    # will add the users authentication token to our version of ngrok to unlock the
    # extended ngrok features
    #
    # #### Paramters
    #
    # * `ctx` - running context from your command
    # * `token` - authentication token provided by ngrok for extended features
    #
    def auth(ctx, token)
      install(ctx)
      ctx.system(File.join(ShopifyCli::CACHE_DIR, 'ngrok'), 'authtoken', token)
    end

    ##
    # will return the statistics of the current running tunnels
    #
    # #### Returns
    #
    # * `stats` - the hash of running statistics returning from the ngrok api
    #
    def stats
      response = Net::HTTP.get_response(NGROK_TUNNELS_URI)
      JSON.parse(response.body)
    rescue
      {}
    end

    ##
    # will return the urls of the current running tunnels
    #
    # #### Returns
    #
    # * `stats` - the array of urls
    #
    def urls
      tunnels = stats.dig(TUNNELS_FIELD)
      tunnels.map { |tunnel| tunnel.dig(PUBLIC_URL_FIELD) }
    rescue
      []
    end

    private

    def install(ctx)
      return if File.exist?(File.join(ShopifyCli::CACHE_DIR, ctx.windows? ? 'ngrok.exe' : 'ngrok'))
      spinner = CLI::UI::SpinGroup.new
      spinner.add('Installing ngrok...') do
        zip_dest = File.join(ShopifyCli::CACHE_DIR, 'ngrok.zip')
        unless File.exist?(zip_dest)
          ctx.system('curl', '-o', zip_dest, DOWNLOAD_URLS[ctx.os], chdir: ShopifyCli::CACHE_DIR)
        end
        ctx.system('tar', '-xf', zip_dest, chdir: ShopifyCli::CACHE_DIR)
        ctx.rm(zip_dest)
      end
      spinner.wait
    end

    def fetch_url(ctx, log_path)
      LogParser.new(log_path)
    rescue RuntimeError => e
      stop(ctx)
      raise e.class, e.message
    end

    def ngrok_command(port)
      "#{File.join(ShopifyCli::CACHE_DIR, 'ngrok')} http -log=stdout -log-level=debug #{port}"
    end

    class LogParser # :nodoc:
      TIMEOUT = 10

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

        raise FetchUrlError, Context.message('core.tunnel.error.url_fetch_failure') unless url
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

    private_constant :LogParser
  end
end
