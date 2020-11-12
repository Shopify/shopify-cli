require 'net/http'

module ShopifyCli
  class HttpRequest
    def self.call(uri, body, headers, method)
      http = ::Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = if method == "POST"
        ::Net::HTTP::Post.new(uri.request_uri)
      elsif method == "GET"
        ::Net::HTTP::Get.new(uri.request_uri)
      end
      req.body = body unless body.nil?
      req['Content-Type'] = 'application/json'
      headers.each { |header, value| req[header] = value }
      http.request(req)
    end
  end
end
