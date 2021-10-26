require "test_helper"
require "shopify_cli/http_request"

module ShopifyCLI
  class APITest < MiniTest::Test
    class TestAPI < API
      def call_load_query(query_name)
        load_query(query_name)
      end
    end

    def setup
      super
      @mutation = <<~MUTATION
        mutation {
          fakeMutation(input: {
            title: "fake title"
          }) {
            id
          }
        }
      MUTATION
      @api = API.new(
        ctx: @context,
        auth_header: "Auth",
        token: "faketoken",
        url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      )
      ShopifyCLI.stubs(:sha).returns("abcde")
      @context.stubs(:uname).returns("Mac")
    end

    def test_mutation_makes_request_to_shopify
      headers = {
        "User-Agent" => "Shopify CLI; v=#{ShopifyCLI::VERSION}",
        "Sec-CH-UA" => "Shopify CLI; v=#{ShopifyCLI::VERSION} sha=#{ShopifyCLI.sha}",
        "Sec-CH-UA-PLATFORM" => @context.os.to_s,
        "Auth" => "faketoken",
        "X-Request-Id" => "1234-5678",
      }
      uri = URI.parse("https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json")
      variables = { var_name: "var_value" }
      body = JSON.dump(query: @mutation.tr("\n", ""), variables: variables)
      File.stubs(:read)
        .with(File.join(ShopifyCLI::ROOT, "lib/graphql/api/mutation.graphql"))
        .returns(@mutation)
      SecureRandom.stubs(:uuid).returns("1234-5678")
      response = stub("response", code: "200", body: "{}")
      HttpRequest.expects(:post).with(uri, body, headers).returns(response)
      @api.query("api/mutation", variables: variables)
    end

    def test_raises_error_with_invalid_url
      File.stubs(:read)
        .with(File.join(ShopifyCLI::ROOT, "lib/graphql/api/mutation.graphql"))
        .returns(@mutation)
      api = API.new(
        ctx: @context,
        auth_header: "Auth",
        token: "faketoken",
        url: "https//https://invalidurl",
      )

      assert_raises(ShopifyCLI::Abort) do
        api.query("api/mutation")
      end
    end

    def test_query_fails_gracefully_with_internal_server_error
      response = stub("response", code: "500", body: "{}")
      HttpRequest.expects(:post).returns(response).times(4)
      File.stubs(:read)
        .with(File.join(ShopifyCLI::ROOT, "lib/graphql/api/mutation.graphql"))
        .returns(@mutation)

      @context.expects(:puts).with(@context.message("core.api.error.internal_server_error"))
      # @context.expects(:debug).times(2)
      @api.query("api/mutation")
      @api.stubs(:query).raises(API::APIRequestServerError)
      assert_raises(API::APIRequestServerError) do
        @api.query("api/mutation")
      end
    end

    def test_query_fails_gracefully_with_internal_server_error_on_debug_mode
      @context.stubs(:getenv).with("DEBUG").returns(true)
      response = stub("response", code: "500", body: "{}")
      HttpRequest.expects(:post).returns(response).times(4)
      File.stubs(:read)
        .with(File.join(ShopifyCLI::ROOT, "lib/graphql/api/mutation.graphql"))
        .returns(@mutation)
      SecureRandom.stubs(:uuid).returns("1234-5678")

      @context.expects(:debug)
        .with(any_of(
          @context.message("core.api.error.internal_server_error_debug", "500\n{}"),
          @context.message("POST #{@api.url} with X-Request-Id: 1234-5678"),
        )).at_least_once
      @context.expects(:puts).with(@context.message("core.api.error.internal_server_error"))
      @api.query("api/mutation")
      @api.stubs(:query).raises(API::APIRequestServerError)
      assert_raises(API::APIRequestServerError) do
        @api.query("api/mutation")
      end
    end

    def test_query_fails_gracefully_with_unexpected_error
      response = stub("response", code: "600", body: "{}")
      HttpRequest.expects(:post).returns(response)
      File.stubs(:read)
        .with(File.join(ShopifyCLI::ROOT, "lib/graphql/api/mutation.graphql"))
        .returns(@mutation)

      @context.expects(:puts).with(@context.message("core.api.error.internal_server_error"))
      @api.query("api/mutation")
      @api.stubs(:query).raises(API::APIRequestUnexpectedError)
      assert_raises(API::APIRequestUnexpectedError) do
        @api.query("api/mutation")
      end
    end

    def test_load_query_can_load_project_type_queries
      new_api = TestAPI.new(ctx: Context.new, token: "blah", url: "alsoblah")
      ShopifyCLI::Project.expects(:current_project_type).returns(:fake)

      expected_path = File.join(ShopifyCLI::ROOT, "lib", "project_types", "fake", "graphql", "my_query.graphql")
      File.expects(:exist?).with(expected_path).returns(true)
      File.expects(:read).with(expected_path).returns("content")

      assert_equal("content", new_api.call_load_query("my_query"))
    end

    def test_load_query_will_fall_back_to_core_queries
      new_api = TestAPI.new(ctx: Context.new, token: "blah", url: "alsoblah")
      ShopifyCLI::Project.expects(:current_project_type).returns(:fake)

      project_type_path = File.join(ShopifyCLI::ROOT, "lib", "project_types", "fake", "graphql", "my_query.graphql")
      File.expects(:exist?).with(project_type_path).returns(false)

      expected_path = File.join(ShopifyCLI::ROOT, "lib", "graphql", "my_query.graphql")
      File.expects(:read).with(expected_path).returns("content")

      assert_equal("content", new_api.call_load_query("my_query"))
    end

    def test_load_query_will_not_read_project_type_queries_if_not_in_project
      new_api = TestAPI.new(ctx: Context.new, token: "blah", url: "alsoblah")
      ShopifyCLI::Project.expects(:current_project_type).returns(nil)
      expected_path = File.join(ShopifyCLI::ROOT, "lib", "graphql", "my_query.graphql")
      File.expects(:read).with(expected_path).returns("content")
      assert_equal("content", new_api.call_load_query("my_query"))
    end

    def test_include_shopify_cli_header_if_acting_as_shopify_organization
      Shopifolk.act_as_shopify_organization
      File.stubs(:read)
        .with(File.join(ShopifyCLI::ROOT, "lib/graphql/api/mutation.graphql"))
        .returns(@mutation)
      mutation = JSON.dump(query: @mutation.tr("\n", ""), variables: {})
      response = stub("response", code: "200", body: "{}")
      HttpRequest
        .expects(:post)
        .with(anything, mutation, has_entry({ "X-Shopify-Cli-Employee" => "1" }))
        .returns(response)
      @api.query("api/mutation")
      Shopifolk.reset
    end

    def test_supports_delete_method
      response = stub("response", code: "200", body: "{}")
      HttpRequest
        .expects(:delete)
        .returns(response)
      @api.request(url: "https://shop.com/api.json", method: "DELETE")
    end
  end
end
