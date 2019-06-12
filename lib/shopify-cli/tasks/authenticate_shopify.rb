require 'shopify_cli'
require 'base64'
require 'securerandom'
require 'socket'
require 'net/http'
require 'uri'
require 'json'

module ShopifyCli
  module Tasks
    class AuthenticateShopify < ShopifyCli::Task
      PORT = 3456
      REDIRECT_URI = "http://localhost:#{PORT}/"

      def call(ctx)
        @ctx = ctx
        server = TCPServer.new('localhost', PORT)
        @ctx.puts("opening #{authorize_url}")
        @ctx.system("open '#{authorize_url}'")
        code = wait_for_redirect(server)
        case res = send_token_request(code)
        when Net::HTTPSuccess
          body = JSON.parse(res.body)
          @env = Helpers::AccessToken.write(body)
          @ctx.puts "{{success:Token stored!}}"
        else
          @ctx.puts("{{error:Response was #{res.body}}}")
          @ctx.puts("{{error:Failed to retrieve ID & Refresh tokens}}")
        end
      end

      def wait_for_redirect(server)
        socket = server.accept # Wait for redirect
        @ctx.puts "Authenticated"
        request = socket.gets

        unless extract_query_param('state', request) == state_token
          socket.close
          raise(StandardError, "Anti-forgery state token does not match the initial request.")
        end

        socket.print("HTTP/1.1 200\r\n")
        socket.print("Content-Type: text/plain\r\n\r\n")
        socket.print("SUCCESS - please return to the CLI for the rest of this process.")
        socket.close
        extract_query_param("code", request)
      end

      def send_token_request(code)
        uri = URI("https://#{env.shop}/admin/oauth/access_token")
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(uri.path)
        request.body = URI.encode_www_form(
          client_id: env.api_key,
          client_secret: env.secret,
          code: code
        )
        @ctx.puts "Fetching tokens..."
        https.request(request)
      end

      def authorize_url
        params = {
          client_id: env.api_key,
          scope: env.scopes,
          redirect_uri: REDIRECT_URI,
          state: state_token,
          'grant_options[]' => 'per user',
        }
        uri = URI.parse("https://#{env.shop}/admin/oauth/authorize")
        uri.query = URI.encode_www_form(params)
        uri
      end

      def project
        @project = ShopifyCli::Project.current
      end

      def env
        @env = Helpers::EnvFile.read(project.app_type, File.join(project.directory, '.env'))
      end

      def extract_query_param(key, request)
        paramstring = request.split('?')[1]
        paramstring = paramstring.split(' ')[0]
        URI.decode_www_form(paramstring).assoc(key).last
      end

      def state_token
        @state_token ||= SecureRandom.hex(30)
      end
    end
  end
end
