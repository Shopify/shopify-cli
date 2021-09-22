module ShopifyCLI
  class IdentityAuth
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
        <script>window.close();</script>
      }

      def initialize(server, identity_auth, token)
        super
        @server = server
        @identity_auth = identity_auth
        @state_token = token
      end

      def do_GET(req, res) # rubocop:disable Naming/MethodName
        if !req.query["error"].nil?
          respond_with(
            res,
            400,
            Context.message("core.identity_auth.servlet.invalid_request_response", req.query["error_description"])
          )
        elsif req.query["state"] != @state_token
          response_message = Context.message("core.identity_auth.servlet.invalid_state_response")
          req.query.merge!("error" => "invalid_state", "error_description" => response_message)
          respond_with(res, 403, response_message)
        else
          respond_with(res, 200, Context.message("core.identity_auth.servlet.success_response"))
        end
        @identity_auth.response_query = req.query
        @server.shutdown
      end

      def respond_with(response, status, message)
        successful = status == 200
        locals = {
          status: status,
          message: message,
          color: successful ? "black" : "red",
          title: Context.message(
            successful ? "core.identity_auth.servlet.authenticated" : "core.identity_auth.servlet.not_authenticated"
          ),
          autoclose: successful ? AUTOCLOSE_TEMPLATE : "",
        }
        response.status = status
        response.body = format(TEMPLATE, locals)
      end
    end
  end
end
