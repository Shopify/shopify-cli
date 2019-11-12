require 'test_helper'

module ShopifyCli
  module Commands
    class Populate
      class ResourceTest < MiniTest::Test
        include TestHelpers::Project
        include TestHelpers::Schema

        def setup
          super
          @resource = Product.new(@context)
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
          ShopifyCli::Helpers::AdminAPI.stubs(:new).returns(Object.new)
        end

        def test_with_schema_args_overrides_input
          @resource.expects(:run_mutation).times(1)
          @resource.call([
            '-c 1', '--title="bad jeggings"', '--variants=[{price: "4.99"}]'
          ], nil)
          assert_equal('"bad jeggings"', @resource.input['title'])
          assert_equal('[{price: "4.99"}]', @resource.input['variants'])
        end

        def test_populate_runs_mutation_default_number_of_times
          @resource.expects(:run_mutation).times(Product::DEFAULT_COUNT)
          @resource.call([], nil)
        end

        def test_populate_runs_mutation_count_number_of_times
          @resource.expects(:run_mutation).times(2)
          @resource.call(['-c 2'], nil)
        end

        def test_populate_runs_mutation_against_other_shop
          Helpers::AdminAPI.expects(:query).with(
            @context, 'create_product', has_entry(shop: 'my-other-test-shop.myshopify.com')
          ).returns(Hash.new)
          capture_io do
            @resource.call(['--silent', '-c 1', '--shop=my-other-test-shop.myshopify.com'], nil)
          end
        end

        def test_populate_with_help_flag_shows_options
          CLI::UI::Terminal.stubs(:height).returns(10000)
          @resource.expects(:run_mutation).never
          io = capture_io do
            @resource.call(['-h'], nil)
          end.join
          assert_match(/Product.*options/, io)
          assert_match(@resource.resource_options.help, io)
        end
      end
    end
  end
end
