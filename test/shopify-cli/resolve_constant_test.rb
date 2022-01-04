# typed: ignore
module ShopifyCLI
  class ResolveConstantTest < MiniTest::Test
    def test_defaults_to_kernel_namespace
      assert_equal Object, ResolveConstant.call(:object).value
    end

    def test_toplevel_namespace_is_configurable
      assert_equal ::MiniTest::Test, ResolveConstant.call(:test, namespace: MiniTest).value
    end

    def test_handles_seperators_correctly
      assert_equal OpenStruct, ResolveConstant.call(:open_struct).value
      assert_equal OpenStruct, ResolveConstant.call("open-struct").value
    end

    def test_traverse_namespace
      assert_equal ::MiniTest::Test, ResolveConstant.call("mini_test/test").value
      assert_equal ::MiniTest::Test, ResolveConstant.call("mini_test::test").value
    end
  end
end
