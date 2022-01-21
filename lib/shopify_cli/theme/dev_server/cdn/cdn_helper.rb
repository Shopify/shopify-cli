# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      module Cdn
        module CdnHelper
          def proxy_request(env, uri, theme)
            response = Net::HTTP.start(uri.host, 443, use_ssl: true) do |http|
              req_class = Net::HTTP.const_get(method(env))

              req = req_class.new(uri)
              req.initialize_http_header(req_headers(theme))
              req.body_stream = req_body(env)

              http.request(req)
            end

            [
              response.code.to_s,
              {
                "Content-Type" => response.content_type,
                "Content-Length" => response.content_length.to_s,
              },
              [response.body],
            ]
          end

          private

          def method(env)
            env["REQUEST_METHOD"].capitalize
          end

          def req_body(env)
            env["rack.input"]
          end

          def req_headers(theme)
            {
              "Referer" => "https://#{theme.shop}",
              "Transfer-Encoding" => "chunked",
            }
          end
        end
      end
    end
  end
end
