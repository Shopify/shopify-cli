require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::SingularType do
  describe ".new" do
    it "should construct and return proper fields" do
      discount_type = ShopifyCli::ScriptModule::Infrastructure::SingularType.new("Discount", "foo", "Discount")
      assert_equal "", discount_type.wrapper
      assert_equal discount_type.ts_type, discount_type.constructor_type
      assert_equal "foo", discount_type.assignment_rhs_type

      id_type = ShopifyCli::ScriptModule::Infrastructure::SingularType.new("ID!", "foo", "u64")
      assert_equal id_type.ts_type, id_type.constructor_type
      assert_equal "foo", id_type.assignment_rhs_type

      int_type = ShopifyCli::ScriptModule::Infrastructure::SingularType.new("Int!", "foo", "i32")
      assert_equal int_type.ts_type, int_type.constructor_type
      assert_equal "foo", int_type.assignment_rhs_type

      string_type = ShopifyCli::ScriptModule::Infrastructure::SingularType.new("String!", "bar", "Str")
      assert_equal "String", string_type.constructor_type
      assert_equal "Str.from(bar)", string_type.assignment_rhs_type
    end
  end
end
