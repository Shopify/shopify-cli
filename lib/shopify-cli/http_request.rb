require 'net/http'

module ShopifyCli
  class HttpRequest
    def self.call(uri, body, variables, headers)
      http = ::Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = ::Net::HTTP::Post.new(uri.request_uri)
      req.body = JSON.dump(query: body.tr("\n", ""), variables: variables)
      req['Content-Type'] = 'application/json'
      headers.each { |header, value| req[header] = value }
      http.request(req)
    end
  end
end
