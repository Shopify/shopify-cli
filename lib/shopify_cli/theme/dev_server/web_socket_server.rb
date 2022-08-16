# frozen_string_literal: true

require "webrick"
require "stringio"

module ShopifyCLI
  module Theme
    module DevServer
      class Server < ::WEBrick::HTTPServer
        def initialize(**args, &block)
          super(args, &block)
        end

        def service(req, res)
          controller, opts, name, path_info = search_servlet(req.path)
          req.script_name = name
          req.path_info = path_info
          raise ::WEBrick::HTTPStatus::NotFound unless handler

          controller = controller.get_instance(self, *opts)
          if controller.is_a?(WebSocketHandler) && req['upgrade'] == 'websocket'
            # handle creation of websocket connection and add connection to handler list
          else
            controller.service(req, res)
          end
        end
      end

      class WebSocketHandler < ::WEBrick::HTTPServlet::AbstractServlet
        attr_accessor :conns

        def initialize(server, *options)
          super(server)
          @conns = []
          @mut = Mutex.new
        end

        def add_conn(socket)
          @mut.synchronize do
            @conns << socket
          end
        end

        def broadcast(updates)
          @conns.each do |conn|
            conn.send(:notify, updates)
          end
        end

        private

        def close_conn(socket)
          @mut.synchronize do
            @conns.delete socket
          end
        end
      end
    end
  end
end
