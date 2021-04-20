require "net/http"

module ShopifyCli
  class HttpRequest
    class << self
      def post(uri, body, headers)
        req = ::Net::HTTP::Post.new(uri.request_uri)
        request(uri, body, headers, req)
      end

      def put(uri, body, headers)
        req = ::Net::HTTP::Put.new(uri.request_uri)
        request(uri, body, headers, req)
      end

      def get(uri, body, headers)
        req = ::Net::HTTP::Get.new(uri.request_uri)
        request(uri, body, headers, req)
      end

      def delete(uri, body, headers)
        req = ::Net::HTTP::Delete.new(uri.request_uri)
        request(uri, body, headers, req)
      end

      def request(uri, body, headers, req)
        http = ::Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        req.body = body unless body.nil?
        req["Content-Type"] = "application/json"
        headers.each { |header, value| req[header] = value }
        http.request(req)
      end
    end
  end
end
