require 'test_helper'

module ShopifyCli
  module Commands
    class PopulateTest < MiniTest::Test
      include TestHelpers::Project

      def setup
        super
        @command = ShopifyCli::Commands::Populate.new(@context)
        Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Populate.help)
        @command.call([], nil)
      end

      def test_with_products_calls_product_resource_with_default_count
        Populate::Product.expects(:call).with(['products'], 'products')
        @command.class.call(['products'], nil)
      end

      def test_with_count_flag_calls_product_resource_with_default_count
        Populate::Product.expects(:call).with(['products', '--count=10'], 'products')
        @command.class.call(['products', '--count=10'], nil)
      end

      def test_with_customers_arg_calls_customer_resource
        Populate::Customer.expects(:call).with(['customers', '--count=10'], 'customers')
        @command.class.call(['customers', '--count=10'], nil)
      end

      def test_with_draftorders_arg_calls_draftorder_resource
        Populate::DraftOrder.expects(:call).with(['draftorders', '--count=10'], 'draftorders')
        @command.class.call(['draftorders', '--count=10'], nil)
      end
    end
  end
end
