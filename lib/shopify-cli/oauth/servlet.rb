module ShopifyCli
  class OAuth
    class Servlet < WEBrick::HTTPServlet::AbstractServlet
      TEMPLATE = %{<!DOCTYPE html>
        <html>
        <head>
          <title>%{title}</title>
        </head>
        <body>
          <h1 style="color: #%{color};">%{message}</h1>
          %{autoclose}
        </body>
        </html>
      }
      AUTOCLOSE_TEMPLATE = %{
        <script>
          setTimeout(function() { window.close(); }, 3000)
        </script>
      }
      SUCCESS_RESP = 'Authenticated Successfully, this page will close shortly.'
      INVALID_STATE_RESP = 'Anti-forgery state token does not match the initial request.'

      def initialize(server, oauth, token)
        super
        @server = server
        @oauth = oauth
        @state_token = token
      end

      def do_GET(req, res) # rubocop:disable Naming/MethodName
        if !req.query['error'].nil?
          respond_with(res, 400, "Invalid Request: #{req.query['error_description']}")
        elsif req.query['state'] != @state_token
          req.query.merge!('error' => 'invalid_state', 'error_description' => INVALID_STATE_RESP)
          respond_with(res, 403, INVALID_STATE_RESP)
        else
          respond_with(res, 200, SUCCESS_RESP)
        end
        @oauth.response_query = req.query
        @server.shutdown
      end

      def respond_with(response, status, message)
        successful = status == 200
        locals = {
          status: status,
          message: message,
          color: successful ? 'black' : 'red',
          title: successful ? 'Authenticate Successfully' : 'Failed to Authenticate',
          autoclose: successful ? AUTOCLOSE_TEMPLATE : '',
        }
        response.status = status
        response.body = format(TEMPLATE, locals)
      end
    end
  end
end
