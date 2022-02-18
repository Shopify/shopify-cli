require "json"
require "fileutils"
require "shopify_cli"
require "forwardable"
require "uri"

module ShopifyCLI
  ##
  # Wraps around localtunnel functionality to allow you to spawn a proccess in the
  # background and stop the process when you need to. It also allows control over
  # the process between application runs.
  class Tunnel
    extend SingleForwardable

    def_delegators :new, :start, :stop, :url

    class TunnelError < RuntimeError; end

    PORT = 8081 # port that the tunnel will bind to

    ##
    # will find and stop a running tunnel process. It will also output if the
    # operation was successful or not
    #
    # #### Paramters
    #
    # * `ctx` - running context from your command
    #
    def stop(ctx)
      if running?
        if ShopifyCLI::ProcessSupervision.stop(:tunnel)
          ctx.puts(ctx.message("core.tunnel.stopped"))
        else
          ctx.abort(ctx.message("core.tunnel.error.stop"))
        end
      else
        ctx.puts(ctx.message("core.tunnel.not_running"))
      end
    end

    ##
    # start will start a running tunnel process running in the background. It will
    # also output the success of this operation
    #
    # #### Paramters
    #
    # * `ctx` - running context from your command
    # * `port` - port to use to open the tunnel
    #
    # #### Returns
    #
    # * `url` - the url that the tunnel is now bound to and available to the public
    #
    def start(ctx, port: PORT)
      url = start_tunnel(ctx, port)
      ctx.puts(ctx.message("core.tunnel.start", url))
      url
    end

    ##
    # Returns the url of the current tunnel or nil if it is not running
    #
    # #### Returns
    #
    # * url of the tunnel / nil
    #
    def url(ctx)
      return nil unless running?

      process = ShopifyCLI::ProcessSupervision.for_ident(:tunnel)
      fetch_url(ctx, process.log_path)
    end

    private

    def running?
      ShopifyCLI::ProcessSupervision.running?(:tunnel)
    end

    def fetch_url(ctx, log_path)
      LogParser.new(log_path).url
    rescue RuntimeError => e
      stop(ctx)
      raise e.class, e.message
    end

    def start_tunnel(ctx, port)
      # check_prereq_command(ctx, "npx")
      command = "npx --yes localtunnel --port #{port}"
      process = ShopifyCLI::ProcessSupervision.start(:tunnel, command)
      fetch_url(ctx, process.log_path)
    end

    # def check_prereq_command(ctx, command)
    #   cmd_path = ctx.which(command)
    #   ctx.abort(ctx.message("core.tunnel.error.prereq_command_required", command)) if cmd_path.nil?
    #   ctx.done(ctx.message("core.tunnel.prereq_command_location", command, cmd_path))
    # end
  end

  class LogParser # :nodoc:
    class FetchUrlError < RuntimeError; end

    TIMEOUT = 20

    attr_reader :url

    def initialize(log_path)
      TIMEOUT.times do
        parse(log_path)
        return if url
        sleep(0.5)
      end

      raise FetchUrlError, Context.message("core.tunnel.error.url_fetch_failure") unless url
    end

    def parse(log_path)
      log = File.read(log_path)
      @url = log.match(/(https\:\/\/.*loca.lt)/).to_a.first
    end
  end
end
