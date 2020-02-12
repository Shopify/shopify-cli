# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Forms
    class CreateAppTest < MiniTest::Test
      include TestHelpers::Partners

      def test_accepts_the_extension_name_as_positional_argument
        form = CreateExtension.ask(@context, ['test-extension'], type: 'product-details')
        assert_equal form.name, 'test-extension'
      end

      def test_accepts_product_details_as_type
        form = CreateExtension.ask(@context, ['test-extension'], type: 'product-details')
        assert_equal form.type, 'product-details'
      end

      def test_accepts_customer_details_as_type
        form = CreateExtension.ask(@context, ['test-extension'], type: 'customer-details')
        assert_equal form.type, 'customer-details'
      end

      def test_prompts_the_user_to_choose_a_type_if_an_unknown_type_was_provided_as_flag
        CLI::UI::Prompt.expects(:ask).with('What type of extension would you like to create?')

        io = capture_io do
          CreateExtension.ask(@context, ['test-extension'], type: 'unknown-type')
        end 

        assert_match('Invalid Extension Type.', io.join)
      end

      def test_prompts_the_user_to_choose_a_type_if_an_no_type_was_provided
        CLI::UI::Prompt.expects(:ask).with('What type of extension would you like to create?')

        capture_io do
          CreateExtension.ask(@context, ['test-extension'], type: nil)
        end 
      end
    end
  end
end
