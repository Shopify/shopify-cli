# frozen_string_literal: true

require "webrick"
require "stringio"

module ShopifyCLI
  module Theme
    class DevServer
      # WEBrick will sometimes cause a fatal deadlock error on shutdown.
      # The error happens because `Thread#join` is called without a timeout argument.
      # We monkey-patch WEBrick to call `Thread#join(timeout)` before the existing
      # `Thread#join`.
      module WEBrickGenericServerThreadJoinWithTimeout
        # Hook into a method called right before the threads are shutdown.
        def cleanup_listener
          # Force a Thread#join with a timeout to prevent any deadlock error on stop
          Thread.list.each do |thread|
            next unless thread[:WEBrickThread]
            thread.join(2)
            # Prevent the `join` call without a timeout inside WEBrick.
            thread[:WEBrickThread] = false
          end
          super
        end
      end

      # Base on Rack::Handler::WEBrick
      class WebServer < ::WEBrick::HTTPServlet::AbstractServlet
        def self.run(app, **options)
          environment  = ENV["RACK_ENV"] || "development"
          default_host = environment == "development" ? "localhost" : nil

          if !options[:BindAddress] || options[:Host]
            options[:BindAddress] = options.delete(:Host) || default_host
          end
          options[:Port] ||= 8080
          if options[:SSLEnable]
            require "webrick/https"
          end

          @server = ::WEBrick::HTTPServer.new(options)
          @server.extend(WEBrickGenericServerThreadJoinWithTimeout)
          @server.mount("/", WebServer, app)
          yield @server if block_given?
          @server.start
        end

        def self.valid_options
          environment  = ENV["RACK_ENV"] || "development"
          default_host = environment == "development" ? "localhost" : "0.0.0.0"

          {
            "Host=HOST" => "Hostname to listen on (default: #{default_host})",
            "Port=PORT" => "Port to listen on (default: 8080)",
          }
        end

        def self.shutdown
          if @server
            @server.shutdown
            @server = nil
          end
        end

        def initialize(server, app)
          super(server)
          @app = app
        end

        def service(req, res)
          # res.rack = true
          env = req.meta_vars
          env.delete_if { |_k, v| v.nil? }

          rack_input = StringIO.new(req.body.to_s)
          rack_input.set_encoding(Encoding::BINARY)

          env.update(
            "rack.version"      => [1, 3],
            "rack.input"        => rack_input,
            "rack.errors"       => $stderr,
            "rack.multithread"  => true,
            "rack.multiprocess" => false,
            "rack.run_once"     => false,
            "rack.url_scheme"   => ["yes", "on", "1"].include?(env["HTTPS"]) ? "https" : "http",
            "rack.hijack?"      => true,
            "rack.hijack"       => lambda { raise NotImplementedError, "only partial hijack is supported." },
            "rack.hijack_io"    => nil
          )

          env["HTTP_VERSION"] ||= env["SERVER_PROTOCOL"]
          env["QUERY_STRING"] ||= ""
          unless env["PATH_INFO"] == ""
            path = req.request_uri.path
            n = env["SCRIPT_NAME"].length
            env["PATH_INFO"] = path[n, path.length - n]
          end
          env["REQUEST_PATH"] ||= [env["SCRIPT_NAME"], env["PATH_INFO"]].join

          status, headers, body = @app.call(env)

          res.status = status.to_i
          io_lambda = nil
          headers.each do |k, vs|
            if k == "rack.hijack"
              io_lambda = vs
            elsif k == "webrick.chunked"
              res.chunked = true
            elsif k.downcase == "set-cookie"
              res.cookies.concat(vs.split("\n"))
            else
              # Since WEBrick won't accept repeated headers,
              # merge the values per RFC 1945 section 4.2.
              res[k] = vs.split("\n").join(", ")
            end
          end

          if io_lambda
            rd, wr = IO.pipe
            res.body = rd
            res.chunked = true
            io_lambda.call(wr)
            body.close if body.respond_to?(:close)
          elsif body.respond_to?(:to_path)
            res.body = ::File.open(body.to_path, "rb")
            body.close if body.respond_to?(:close)
          else
            res.body = lambda do |out|
              out.set_encoding(Encoding::BINARY) if out.respond_to?(:set_encoding)
              body.each do |part|
                out.write(part)
              end
              body.close if body.respond_to?(:close)
            end
          end
        end
      end
    end
  end
end
