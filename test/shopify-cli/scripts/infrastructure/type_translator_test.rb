require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::TypeTranslator do
  describe ".slice?" do
    it "should return if slice or not" do
      line_item_array_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("[LineItem!]", "foo")
      assert line_item_array_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::PluralType)
      assert_equal "Slice<LineItem>", line_item_array_type.ts_type

      product_array_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("[Product]!", "foo")
      assert product_array_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::PluralType)
      assert_equal "Slice<Product>", product_array_type.ts_type

      discount_code_array_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("[DiscountCode]", "foo")
      assert discount_code_array_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::PluralType)
      assert_equal "Slice<DiscountCode>", discount_code_array_type.ts_type

      discount_array_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("[Discount!]!", "foo")
      assert discount_array_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::PluralType)
      assert_equal "Slice<Discount>", discount_array_type.ts_type

      discount_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("Discount", "foo")
      assert discount_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::SingularType)
      assert_equal "Discount", discount_type.ts_type

      product_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("Product!", "foo")
      assert product_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::SingularType)
      assert_equal "Product", product_type.ts_type

      id_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("ID!", "foo")
      assert id_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::SingularType)
      assert_equal "ID", id_type.ts_type

      int_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("Int!", "foo")
      assert int_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::SingularType)
      assert_equal "Int", int_type.ts_type

      id_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("Float", "foo")
      assert id_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::SingularType)
      assert_equal "Float", id_type.ts_type

      int_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("Boolean", "foo")
      assert int_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::SingularType)
      assert_equal "bool", int_type.ts_type

      string_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("String!", "foo")
      assert string_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::SingularType)
      assert_equal "Str", string_type.ts_type

      string_type_1 = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("String!", "foo")
      assert string_type_1.instance_of?(ShopifyCli::ScriptModule::Infrastructure::SingularType)
      assert_equal "Str", string_type_1.ts_type

      string_slice_type = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("[String!]", "foo")
      assert string_slice_type.instance_of?(ShopifyCli::ScriptModule::Infrastructure::PluralType)
      assert_equal "Slice<Str>", string_slice_type.ts_type

      string_slice_type_1 = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("[String]", "foo")
      assert string_slice_type_1.instance_of?(ShopifyCli::ScriptModule::Infrastructure::PluralType)
      assert_equal "Slice<Str>", string_slice_type_1.ts_type

      string_slice_type_2 = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("[String]!", "foo")
      assert string_slice_type_2.instance_of?(ShopifyCli::ScriptModule::Infrastructure::PluralType)
      assert_equal "Slice<Str>", string_slice_type_2.ts_type

      string_slice_type_3 = ShopifyCli::ScriptModule::Infrastructure::TypeTranslator.new.translate("[String!]!", "foo")
      assert string_slice_type_3.instance_of?(ShopifyCli::ScriptModule::Infrastructure::PluralType)
      assert_equal "Slice<Str>", string_slice_type_3.ts_type
    end
  end
end
