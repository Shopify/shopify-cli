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
        assert_equal(oauth.response_query, { 'state' => 'state_token' })
        assert_equal(resp.status, 200)
        assert_match('Authenticate Successfully', resp.body)
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
        assert_equal(resp.status, 400)
        assert_match('Failed to Authenticate', resp.body)
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
          "error_description" => OAuth::Servlet::INVALID_STATE_RESP,
        })
        assert_equal(resp.status, 403)
        assert_match('Failed to Authenticate', resp.body)
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
