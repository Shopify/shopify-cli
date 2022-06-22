module ShopifyCLI
  class IdentityAuth
    class Servlet < WEBrick::HTTPServlet::AbstractServlet
      ERB_FILENAME = File.join(ROOT, "lib/shopify_cli/assets/post_auth_page/index.html.erb")
      CSS_FILENAME = File.join(ROOT, "lib/shopify_cli/assets/post_auth_page/style.css")

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
          css: File.read(CSS_FILENAME),
        }
        response.status = status
        response.body = ERB.new(File.read(ERB_FILENAME)).result(binding)
      end
    end
  end
end
