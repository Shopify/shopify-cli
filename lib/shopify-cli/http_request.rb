require "net/http"
require "openssl"

module ShopifyCLI
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
        cert_store = OpenSSL::X509::Store.new
        cert_store.set_default_paths

        http = ::Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.cert_store = cert_store
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE if ENV["SSL_VERIFY_NONE"]

        req.body = body unless body.nil?
        req["Content-Type"] = "application/json"
        headers.each { |header, value| req[header] = value }
        http.request(req)
      end
    end
  end
end
