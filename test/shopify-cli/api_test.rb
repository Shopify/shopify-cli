require 'test_helper'

module ShopifyCli
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
        auth_header: 'Auth',
        token: 'faketoken',
        url: "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json",
      )
      Git.stubs(:sha).returns('abcde')
      @context.stubs(:uname).returns('Mac')
    end

    def test_mutation_makes_request_to_shopify
      stub_request(:post, 'https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json')
        .with(body: File.read(File.join(FIXTURE_DIR, 'api/mutation.json')).tr("\n", ''),
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => "Shopify App CLI #{ShopifyCli::VERSION} abcde | Mac",
            'Auth' => 'faketoken',
          })
        .to_return(status: 200, body: '{}')
      File.stubs(:read)
        .with(File.join(ShopifyCli::ROOT, "lib/graphql/api/mutation.graphql"))
        .returns(@mutation)

      @api.query('api/mutation')
    end

    def test_raises_error_with_invalid_url
      File.stubs(:read)
        .with(File.join(ShopifyCli::ROOT, "lib/graphql/api/mutation.graphql"))
        .returns(@mutation)
      api = API.new(
        ctx: @context,
        auth_header: 'Auth',
        token: 'faketoken',
        url: 'https//https://invalidurl',
      )

      assert_raises(ShopifyCli::Abort) do
        api.query('api/mutation')
      end
    end

    def test_load_query_can_load_project_type_queries
      new_api = TestAPI.new(ctx: Context.new, token: 'blah', url: 'alsoblah')
      ShopifyCli::Project.expects(:current_project_type).returns(:fake)

      expected_path = File.join(ShopifyCli::ROOT, 'lib', 'project_types', 'fake', 'graphql', 'my_query.graphql')
      File.expects(:exist?).with(expected_path).returns(true)
      File.expects(:read).with(expected_path).returns('content')

      assert_equal(new_api.call_load_query('my_query'), 'content')
    end

    def test_load_query_will_fall_back_to_core_queries
      new_api = TestAPI.new(ctx: Context.new, token: 'blah', url: 'alsoblah')
      ShopifyCli::Project.expects(:current_project_type).returns(:fake)

      project_type_path = File.join(ShopifyCli::ROOT, 'lib', 'project_types', 'fake', 'graphql', 'my_query.graphql')
      File.expects(:exist?).with(project_type_path).returns(false)

      expected_path = File.join(ShopifyCli::ROOT, 'lib', 'graphql', 'my_query.graphql')
      File.expects(:read).with(expected_path).returns('content')

      assert_equal(new_api.call_load_query('my_query'), 'content')
    end

    def test_load_query_will_not_read_project_type_queries_if_not_in_project
      new_api = TestAPI.new(ctx: Context.new, token: 'blah', url: 'alsoblah')
      ShopifyCli::Project.expects(:current_project_type).returns(nil)
      expected_path = File.join(ShopifyCli::ROOT, 'lib', 'graphql', 'my_query.graphql')
      File.expects(:read).with(expected_path).returns('content')
      assert_equal(new_api.call_load_query('my_query'), 'content')
    end
  end
end
