require "test_helper"

module ShopifyCli
  class AdminAPI
    class PopulateResourceCommandTest < MiniTest::Test
      include TestHelpers::Project
      include TestHelpers::Schema

      def setup
        super
        ShopifyCli::ProjectType.load_type(:rails)
        @resource = Rails::Commands::Populate::Product.new(@context)
        ShopifyCli::AdminAPI.stubs(:new).returns(Object.new)
      end

      def test_with_schema_args_overrides_input
        @resource.expects(:run_mutation).times(1)
        @resource.call([
          "-c 1", '--title="bad jeggings"', '--variants=[{price: "4.99"}]'
        ], nil)
        assert_equal('"bad jeggings"', @resource.input["title"])
        assert_equal('[{price: "4.99"}]', @resource.input["variants"])
      end

      def test_prompts_and_writes_to_env_if_no_shop
        skip("test to be resumed when populate command hack is properly resolved")
        Project.current.stubs(:env).returns(Resources::EnvFile.new(api_key: "123", secret: "foo"))
        assert_nil(Project.current.env.shop)
        ShopifyCli::Tasks::SelectOrgAndShop.expects(:call)
          .with(@context)
          .returns({ shop_domain: "shopdomain.myshopify.com" })
        Resources::EnvFile.any_instance.expects(:update)
        @resource.expects(:run_mutation).times(Rails::Commands::Populate::Product::DEFAULT_COUNT)
        @resource.call([], nil)
      end

      def test_populate_runs_mutation_default_number_of_times
        @resource.expects(:run_mutation).times(Rails::Commands::Populate::Product::DEFAULT_COUNT)
        @resource.call([], nil)
      end

      def test_populate_runs_mutation_count_number_of_times
        @resource.expects(:run_mutation).times(2)
        @resource.call(["-c 2"], nil)
      end

      def test_populate_runs_mutation_against_other_shop
        skip("test to be resumed when populate command hack is properly resolved")
        ShopifyCli::AdminAPI.expects(:query).with(
          @context, "create_product", has_entry(shop: "my-other-test-shop.myshopify.com")
        ).returns(Hash.new)
        capture_io do
          @resource.call(["--silent", "-c 1", "--shop=my-other-test-shop.myshopify.com"], nil)
        end
      end

      def test_populate_with_help_flag_shows_options
        CLI::UI::Terminal.stubs(:height).returns(10000)
        @resource.expects(:run_mutation).never
        io = capture_io do
          @resource.call(["-h"], nil)
        end.join
        assert_match(/Product.*options/, io)
        assert_match(@resource.resource_options.help, io)
      end
    end
  end
end
