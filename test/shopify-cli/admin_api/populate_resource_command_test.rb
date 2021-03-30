require "test_helper"

module ShopifyCli
  class AdminAPI
    class PopulateResourceCommandTest < MiniTest::Test
      include TestHelpers::Project
      include TestHelpers::Schema

      def setup
        super
        @resource = ShopifyCli::Commands::Populate::Product.new(@context)
        ShopifyCli::AdminAPI.stubs(:new).returns(Object.new)
      end

      def test_with_schema_args_overrides_input
        ShopifyCli::DB.expects(:exists?).with(:shop).returns(true)
        ShopifyCli::DB.expects(:get).with(:shop).returns("my-test-shop.myshopify.io")
        @resource.expects(:run_mutation).times(1)
        @resource.call([
          "-c 1", '--title="bad jeggings"', '--variants=[{price: "4.99"}]'
        ], nil)
        assert_equal('"bad jeggings"', @resource.input["title"])
        assert_equal('[{price: "4.99"}]', @resource.input["variants"])
      end

      def test_if_no_shop
        ShopifyCli::DB.expects(:exists?).with(:shop).returns(false)
        @resource.expects(:run_mutation).never
        exception = assert_raises ShopifyCli::Abort do
          @resource.call([], nil)
        end
        assert_equal(
          "{{x}} " + @context.message("core.populate.error.no_shop", ShopifyCli::TOOL_NAME),
          exception.message
        )
      end

      def test_populate_runs_mutation_default_number_of_times
        ShopifyCli::DB.expects(:exists?).with(:shop).returns(true)
        ShopifyCli::DB.expects(:get).with(:shop).returns("my-test-shop.myshopify.io")
        @resource.expects(:run_mutation).times(ShopifyCli::Commands::Populate::Product::DEFAULT_COUNT)
        @resource.call([], nil)
      end

      def test_populate_runs_mutation_count_number_of_times
        ShopifyCli::DB.expects(:exists?).with(:shop).returns(true)
        ShopifyCli::DB.expects(:get).with(:shop).returns("my-test-shop.myshopify.io")
        @resource.expects(:run_mutation).times(2)
        @resource.call(["-c 2"], nil)
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
