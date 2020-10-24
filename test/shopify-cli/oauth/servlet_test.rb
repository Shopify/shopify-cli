require 'test_helper'
require 'ostruct'
require 'webrick'

module ShopifyCli
  module OAuthTests
    class ServletTest < MiniTest::Test
      Request = Struct.new(:query)
      Response = Struct.new(:status, :body)

      def test_do_get
        server = new_server
        oauth = OpenStruct.new
        servlet = OAuth::Servlet.new(server, oauth, 'state_token')
        resp = Response.new
        servlet.do_GET(Request.new({ 'state' => 'state_token' }), resp)
        assert_equal({ 'state' => 'state_token' }, oauth.response_query)
        assert_equal(200, resp.status)
        assert_match(Context.message('core.oauth.servlet.authenticated'), resp.body)
      end

      def test_oauth_error
        server = new_server
        oauth = OpenStruct.new
        servlet = OAuth::Servlet.new(server, oauth, 'state_token')
        data = {
          "error" => "bad_request",
          "error_description" => "bad url callback",
        }
        resp = Response.new
        servlet.do_GET(Request.new(data), resp)
        assert_equal(oauth.response_query, data)
        assert_equal(400, resp.status)
        assert_match(Context.message('core.oauth.servlet.not_authenticated'), resp.body)
      end

      def test_invalid_state
        server = new_server
        oauth = OpenStruct.new
        servlet = OAuth::Servlet.new(server, oauth, 'state_token')
        resp = Response.new
        servlet.do_GET(Request.new({ 'state' => 'nope' }), resp)
        assert_equal(oauth.response_query, {
          "state" => "nope",
          "error" => "invalid_state",
          "error_description" => Context.message('core.oauth.servlet.invalid_state_response'),
        })
        assert_equal(403, resp.status)
        assert_match(Context.message('core.oauth.servlet.not_authenticated'), resp.body)
      end

      private

      def new_server
        server = Object.new
        server.stubs(:[])
        server.expects(:shutdown)
        server
      end
    end
  end
end
