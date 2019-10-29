require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::PluralType do
  describe ".new" do
    let(:string_wrapper) do
      <<~HEREDOC
        @unmanaged
        export class Strs extends Slice<Str> {
          static fromArray(arr: Array<Str>): Strs {
            return <Strs>Slice.fromArray<Str>(arr);
          }

          @inline
          static from(arr: Array<Str>): Strs {
            return Strs.fromArray(arr);
          }
        }
      HEREDOC
    end
    it "should construct and return proper fields" do
      line_item_array_type = ShopifyCli::ScriptModule::Infrastructure::PluralType.new("[LineItem!]", "foo", "Slice<LineItem>")
      assert_equal "Array<LineItem>", line_item_array_type.constructor_type
      assert_equal "Slice.from<LineItem>(foo)", line_item_array_type.assignment_rhs_type

      string_slice_type = ShopifyCli::ScriptModule::Infrastructure::PluralType.new("[String!]", "foo", "Slice<Str>")
      assert_equal "Array<String>", string_slice_type.constructor_type
      assert_equal "Slice.from<Str>(foo.map(x => Str.from(x)))", string_slice_type.assignment_rhs_type
      assert_equal string_wrapper, string_slice_type.wrapper
    end
  end
end
