# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class Socket
        def initialize(request_socket:, handler:)
          @conn = request_socket
          @handler = handler
        end

        def notify(data)
          #sends message with data
        end

        def close
          # client close socket
          handler.send(:close, self)
        end
      end
    end
  end
end
