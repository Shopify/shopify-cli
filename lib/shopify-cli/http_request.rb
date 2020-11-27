require 'net/http'

module ShopifyCli
  class HttpRequest
    NETWORK_ERRORS = [Net::OpenTimeout,
                      Net::ReadTimeout,
                      EOFError,
                      Errno::ECONNREFUSED,
                      Errno::ECONNRESET,
                      Errno::EHOSTUNREACH,
                      Errno::ETIMEDOUT,
                      SocketError]

    def self.post(uri, body, variables, headers)
      http = ::Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = ::Net::HTTP::Post.new(uri.request_uri)
      req.body = JSON.dump(query: body.tr("\n", ""), variables: variables)
      req['Content-Type'] = 'application/json'
      headers.each { |header, value| req[header] = value }
      http.request(req)
    end

    def self.get(uri, read_timeout:)
      http = ::Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = read_timeout if read_timeout
      http.request_get(uri.path)
    end

    def self.with_network_errors_silenced
      response = nil
      begin
        response = yield
      rescue *NETWORK_ERRORS
        return
      end
      unless response.is_a?(Net::HTTPSuccess)
        return
      end
      response
    end
  end
end
