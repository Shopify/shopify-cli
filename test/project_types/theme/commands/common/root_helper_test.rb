# frozen_string_literal: true

require "project_types/theme/test_helper"
require "project_types/theme/commands/common/root_helper"

module Theme
  class Command
    module Common
      class RootHelperTest < MiniTest::Test
        include Common::RootHelper

        def test_root_value_when_args_is_nil
          assert_equal(".", root_value(nil, nil))
        end

        def test_root_value_when_args_is_empty
          assert_equal(".", root_value([], nil))
        end

        def test_root_value_when_args_is_not_empty
          options = stub(flags: {
            includes: ["layout/password.liquid"],
            ignores: ["layout/password.liquid"],
          })
          assert_equal("dir", root_value(["dir"], options))
        end

        def test_root_value_when_args_is_not_empty_and_options_is_nil
          assert_equal("dir", root_value(["dir"], nil))
        end

        def test_root_value_when_options_include_an_arg_value
          options = stub(flags: {
            includes: ["layout/password.liquid", nil],
            ignores: nil,
          })
          assert_equal(".", root_value(["layout/password.liquid"], options))
        end

        def test_root_value_when_options_ignore_an_arg_value
          options = stub(flags: {
            ignores: ["layout/password.liquid", nil],
            includes: [nil],
          })
          assert_equal(".", root_value(["layout/password.liquid"], options))
        end
      end
    end
  end
end
