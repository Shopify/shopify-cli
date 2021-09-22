require "test_helper"

module ShopifyCLI
  class FormTest < MiniTest::Test
    class TestForm < ShopifyCLI::Form
      positional_arguments :one, :two
      flag_arguments :three, :four

      def ask
        raise ShopifyCLI::Abort, "I was asked to raise" if three == "raise"
      end
    end

    def test_that_all_attributes_are_defined
      TestForm.any_instance.expects(:ask)
      form = TestForm.ask(
        @context,
        ["a", "b", "c", "d"],
        three: "one", four: "two",
      )
      assert_equal("a", form.one)
      assert_equal("b", form.two)
      assert_equal(["c", "d"], form.xargs)
      assert_equal("one", form.three)
      assert_equal("two", form.four)
    end

    def test_that_the_form_returns_nil_if_not_all_pos_args_are_present
      TestForm.any_instance.expects(:ask).never
      form = TestForm.ask(
        @context,
        ["a"],
        {}
      )
      assert_nil(form)
    end

    def test_that_the_form_returns_nil_if_shopify_abort_is_raised
      io = capture_io do
        form = TestForm.ask(
          @context,
          ["a", "b", "c", "d"],
          three: "raise", four: "two",
        )
        assert_nil(form)
      end
      assert_match("I was asked to raise", io.join)
    end
  end
end
