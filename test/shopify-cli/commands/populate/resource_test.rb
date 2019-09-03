require 'test_helper'

module ShopifyCli
  module Commands
    class Populate
      class ResourceTest < MiniTest::Test
        include TestHelpers::Project
        include TestHelpers::Schema

        def setup
          super
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
          ShopifyCli::Helpers::API.stubs(:new).returns(Object.new)
        end

        def test_with_schema_args_overrides_input
          resource = Product.new(@context)
          resource.expects(:run_mutation).times(1)
          resource.call([
            '-c 1', '--title="bad jeggings"', '--variants=[{price: "4.99"}]'
          ], nil)
          assert_equal('"bad jeggings"', resource.input.title)
          assert_equal('[{price: "4.99"}]', resource.input.variants)
        end

        def test_populate_runs_mutation_default_number_of_times
          resource = Product.new(@context)
          resource.expects(:run_mutation).times(Product::DEFAULT_COUNT)
          resource.call([], nil)
        end

        def test_populate_runs_mutation_count_number_of_times
          resource = Product.new(@context)
          resource.expects(:run_mutation).times(2)
          resource.call(['-c 2'], nil)
        end
      end
    end
  end
end
