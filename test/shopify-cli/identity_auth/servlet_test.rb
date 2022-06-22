require "test_helper"
require "ostruct"
require "webrick"

module ShopifyCLI
  module IdentityAuthTests
    class ServletTest < MiniTest::Test
      Request = Struct.new(:query)
      Response = Struct.new(:status, :body)

      def test_do_get
        server = new_server
        identity_auth = OpenStruct.new
        servlet = IdentityAuth::Servlet.new(server, identity_auth, "state_token")
        resp = Response.new
        req = Request.new({ "state" => "state_token" })
        servlet.do_GET(req, resp)
        assert_equal({ "state" => "state_token" }, identity_auth.response_query)
        assert_equal(200, resp.status)
        assert_match(Context.message("core.identity_auth.servlet.success_response"), resp.body)
      end

      def test_identity_auth_error
        server = new_server
        identity_auth = OpenStruct.new
        servlet = IdentityAuth::Servlet.new(server, identity_auth, "state_token")
        data = {
          "error" => "bad_request",
          "error_description" => "bad url callback",
        }
        resp = Response.new
        req = Request.new(data)
        servlet.do_GET(req, resp)
        assert_equal(identity_auth.response_query, data)
        assert_equal(400, resp.status)
        assert_match(
          Context.message("core.identity_auth.servlet.invalid_request_response",
            req.query["error_description"]), resp.body
        )
      end

      def test_invalid_state
        server = new_server
        identity_auth = OpenStruct.new
        servlet = IdentityAuth::Servlet.new(server, identity_auth, "state_token")
        resp = Response.new
        req = Request.new({ "state" => "nope" })
        servlet.do_GET(req, resp)
        assert_equal(identity_auth.response_query, {
          "state" => "nope",
          "error" => "invalid_state",
          "error_description" => Context.message("core.identity_auth.servlet.invalid_state_response"),
        })
        assert_equal(403, resp.status)
        assert_match(Context.message("core.identity_auth.servlet.invalid_state_response"), resp.body)
      end

      private

      def new_server
        server = mock
        server.stubs(:[])
        server.expects(:shutdown)
        server
      end
    end
  end
end
