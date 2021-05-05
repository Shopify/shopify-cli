# frozen_string_literal: true
require "shopify_cli"
require "socket"

module Extension
  module Tasks
    class ChooseNextAvailablePort
      include ShopifyCli::MethodObject

      property! :from
      property! :to, default: -> { from + 25 }
      property! :host, default: "localhost"
      property! :max_tries, default: 25

      def call
        available_port = port_range(from: from, to: to).find { |p| available?(host, p) }
        raise ArgumentError, "Ports between #{from} and #{to} are unavailable" if available_port.nil?
        available_port
      end

      private

      def port_range(from:, to:)
        (from...to)
      end

      def available?(host, port)
        Socket.tcp(host, port, connect_timeout: 1) do |socket|
          socket.close
          false
        end
      rescue Errno::ECONNREFUSED
        true
      end
    end
  end
end
