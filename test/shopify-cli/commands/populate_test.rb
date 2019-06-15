require 'test_helper'

module ShopifyCli
  module Commands
    class PopulateTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @command = ShopifyCli::Commands::Populate.new(@context)
        @context.stubs(:project).returns(
          Project.at(File.join(FIXTURE_DIR, 'app_types/node'))
        )
        Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
      end

      def test_without_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Populate.help)
        @command.call([], nil)
      end

      def test_with_products_calls_product_resource_with_default_count
        Populate::Resource.any_instance.expects(:populate).with(5)
        @command.call(['products'], nil)
      end

      def test_with_count_flag_calls_product_resource_with_default_count
        Populate::Resource.any_instance.expects(:populate).with(10)
        @command.call(['products', '--count=10'], nil)
      end
    end
  end
end
