# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/forms/apply_to_all"

module ShopifyCLI
  module Theme
    class Syncer
      module Forms
        class ApplyToAllTest < Minitest::Test
          def test_apply_when_applies
            number_of_files = 5
            apply_to_all = ApplyToAll.new(@context, number_of_files)

            ApplyToAllForm.expects(:ask)
              .with(@context, [], number_of_files: number_of_files)
              .returns(stub(apply?: true))

            assert(apply_to_all.apply?("value"))
            assert_equal("value", apply_to_all.value)
          end

          def test_apply_when_it_does_not_apply
            number_of_files = 5
            apply_to_all = ApplyToAll.new(@context, number_of_files)

            ApplyToAllForm.expects(:ask)
              .with(@context, [], number_of_files: number_of_files)
              .returns(stub(apply?: false))

            refute(apply_to_all.apply?("value"))
            assert_nil(apply_to_all.value)
          end

          def test_apply_when_number_of_files_is_not_greater_than_one
            number_of_files = 1
            apply_to_all = ApplyToAll.new(@context, number_of_files)

            ApplyToAllForm.expects(:ask).never

            assert_nil(apply_to_all.apply?("value"))
            assert_nil(apply_to_all.value)
          end
        end
      end
    end
  end
end
