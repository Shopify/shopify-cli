require "json"
require "fileutils"
require "shopify_cli"
require "forwardable"
require "uri"

module ShopifyCLI
  ##
  # Wraps around ngrok functionality to allow you to spawn a ngrok proccess in the
  # background and stop the process when you need to. It also allows control over
  # the ngrok process between application runs.
  class Tunnel
    extend SingleForwardable

    def_delegators :new, :start, :stop, :auth, :authenticated?, :stats, :urls, :running_on?

    class FetchUrlError < RuntimeError; end
    class NgrokError < RuntimeError; end

    PORT = 8081 # port that ngrok will bind to
    # mapping for supported operating systems for where to download ngrok from.
    DOWNLOAD_URLS = {
      mac: "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-amd64.zip",
      mac_m1: "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-arm64.zip",
      linux: "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip",
      windows: "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip",
    }

    NGROK_TUNNELS_URI = URI.parse("http://localhost:4040/api/tunnels")
    TUNNELS_FIELD = "tunnels"
    TUNNEL_ADDRESS_KEY_PATH = ["config", "addr"]
    PUBLIC_URL_FIELD = "public_url"

    ##
    # will find and stop a running tunnel process. It will also output if the
    # operation was successful or not
    #
    # #### Paramters
    #
    # * `ctx` - running context from your command
    #
    def stop(ctx)
      if ShopifyCLI::ProcessSupervision.running?(:ngrok)
        if ShopifyCLI::ProcessSupervision.stop(:ngrok)
          ctx.puts(ctx.message("core.tunnel.stopped"))
        else
          ctx.abort(ctx.message("core.tunnel.error.stop"))
        end
      else
        ctx.puts(ctx.message("core.tunnel.not_running"))
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
      ctx.abort(ctx.message("core.tunnel.error.signup_required", ShopifyCLI::TOOL_NAME)) unless authenticated?
      url, account = start_ngrok(ctx, port)
      ctx.puts(ctx.message("core.tunnel.start_with_account", url, account))
      url
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
      ctx.system(ngrok_path(ctx), "authtoken", token)
    end

    ##
    # returns a boolean: if the user has a ngrok token to authenticate
    #
    def authenticated?
      ngrok_config_path = File.join(Dir.home, ".ngrok2/ngrok.yml")
      return false unless File.exist?(ngrok_config_path)
      File.read(ngrok_config_path).include?("authtoken")
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

    ##
    # Returns Boolean if a tunnel is running on a given port
    #
    # #### Parameters
    #
    # * `port` - port to check
    #
    # #### Returns
    #
    # * true / false
    #
    def running_on?(port)
      extract_port = ->(tunnel) { URI(tunnel.dig(*TUNNEL_ADDRESS_KEY_PATH)).port }
      matches_port = ->(occupied_port) { occupied_port == port }
      stats.fetch(TUNNELS_FIELD, []).map(&extract_port).any?(&matches_port)
    rescue
      false
    end

    private

    def install(ctx)
      ngrok = "ngrok#{ctx.executable_file_extension}"
      return if File.exist?(ngrok_path(ctx))
      check_prereq_command(ctx, "curl")
      check_prereq_command(ctx, ctx.linux? ? "unzip" : "tar")
      spinner = CLI::UI::SpinGroup.new
      spinner.add(ctx.message("core.tunnel.installing")) do
        zip_dest = File.join(ShopifyCLI.cache_dir, "ngrok.zip")
        unless File.exist?(zip_dest)
          ctx.system("curl", "-o", zip_dest, DOWNLOAD_URLS[ctx.os], chdir: ShopifyCLI.cache_dir)
        end
        args = if ctx.linux?
          %W(unzip -u #{zip_dest})
        else
          %W(tar -xf #{zip_dest})
        end
        ctx.system(*args, chdir: ShopifyCLI.cache_dir)
        ctx.rm(zip_dest)
      end
      spinner.wait

      # final check to see if ngrok is accessible
      unless File.exist?(ngrok_path(ctx))
        ctx.abort(ctx.message("core.tunnel.error.ngrok", ngrok, ShopifyCLI.cache_dir))
      end
    end

    def fetch_url(ctx, log_path)
      LogParser.new(log_path)
    rescue NgrokError => e
      # Full error messages/descriptions: https://ngrok.com/docs/errors
      case e.message
      when /ERR_NGROK_107/
        ctx.abort(ctx.message("tunnel.invalid_token", e.message))
      when /ERR_NGROK_108/
        ctx.abort(ctx.message("tunnel.duplicate_session", e.message))
      end
      raise e.class, e.message
    rescue RuntimeError => e
      stop(ctx)
      raise e.class, e.message
    end

    def ngrok_path(ctx)
      ngrok = "ngrok#{ctx.executable_file_extension}"
      File.join(ShopifyCLI.cache_dir, ngrok)
    end

    def seconds_to_hm(seconds)
      format("%d hours %d minutes", seconds / 3600, seconds / 60 % 60)
    end

    def start_ngrok(ctx, port)
      ngrok_command = "\"#{ngrok_path(ctx)}\" http -inspect=false -log=stdout -log-level=debug #{port}"
      process = ShopifyCLI::ProcessSupervision.start(:ngrok, ngrok_command)
      log = fetch_url(ctx, process.log_path)
      [log.url, log.account]
    end

    def check_prereq_command(ctx, command)
      cmd_path = ctx.which(command)
      ctx.abort(ctx.message("core.tunnel.error.prereq_command_required", command)) if cmd_path.nil?
      ctx.done(ctx.message("core.tunnel.prereq_command_location", command, cmd_path))
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

        raise FetchUrlError, Context.message("core.tunnel.error.url_fetch_failure") unless url
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
        account, _ = @log.match(/AccountName:(.*)\s+SessionDuration/)&.captures
        @account = account&.empty? ? nil : account
      end

      def error
        @log.scan(/msg="command failed" err="([^"]+)"/).flatten
      end
    end

    private_constant :LogParser
  end
end
