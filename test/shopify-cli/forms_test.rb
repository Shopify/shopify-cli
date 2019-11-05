require 'test_helper'

module ShopifyCli
  class FormsTest < MiniTest::Test
    class TestForm < Forms::Form
      positional_arguments :one, :two
      flag_arguments :three, :four

      def ask
        raise ShopifyCli::Abort, 'I was asked to raise' if three == 'raise'
      end
    end

    def test_that_all_attributes_are_defined
      TestForm.any_instance.expects(:ask)
      form = TestForm.ask(
        @context,
        ['a', 'b', 'c', 'd'],
        three: 'one', four: 'two',
      )
      assert_equal(form.one, 'a')
      assert_equal(form.two, 'b')
      assert_equal(form.xargs, ['c', 'd'])
      assert_equal(form.three, 'one')
      assert_equal(form.four, 'two')
    end

    def test_that_the_form_returns_nil_if_not_all_pos_args_are_present
      TestForm.any_instance.expects(:ask).never
      form = TestForm.ask(
        @context,
        ['a'],
        {}
      )
      assert_nil(form)
    end

    def test_that_the_form_returns_nil_if_shopify_abort_is_raised
      io = capture_io do
        form = TestForm.ask(
          @context,
          ['a', 'b', 'c', 'd'],
          three: 'raise', four: 'two',
        )
        assert_nil(form)
      end
      assert_match('I was asked to raise', io.join)
    end
  end
end
