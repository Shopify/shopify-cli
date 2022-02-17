# frozen_string_literal: true

require "project_types/theme/test_helper"
require "project_types/theme/commands/common/root_helper"

module Theme
  class Command
    module Common
      class RootHelperTest < MiniTest::Test
        include Common::RootHelper

        def test_root_value_when_root_is_nil_and_flags_are_not_present
          options = options_mock([
            "theme",
            "pull",
          ])

          assert_equal(".", root_value(options, "pull"))
        end

        def test_root_value_when_args_is_empty
          options = options_mock([
            "theme",
            "pull",
            "-x",
            "dir",
            "-o",
            "dir",
          ])

          assert_equal(".", root_value(options, "pull"))
        end

        def test_root_value_when_args_root_is_equal_to_flags
          options = options_mock([
            "theme",
            "pull",
            "dir",
            "-x",
            "dir",
            "-o",
            "dir",
          ])

          assert_equal("dir", root_value(options, "pull"))
        end

        def test_root_value_when_args_root_is_not_equal_to_flags
          options = options_mock([
            "theme",
            "pull",
            "dir",
            "-x",
            "sections/announcement-bar.liquid",
            "sections/apps.liquid",
            "sections/cart-icon-bubble.liquid",
            "sections/cart-live-region-text.liquid",
          ])

          assert_equal("dir", root_value(options, "pull"))
        end

        def test_root_value_when_name_is_invalid
          options = options_mock([
            "theme",
            "pull",
            "dir",
            "-x",
            "sections/announcement-bar.liquid",
            "sections/apps.liquid",
            "sections/cart-icon-bubble.liquid",
            "sections/cart-live-region-text.liquid",
          ])

          assert_equal(".", root_value(options, "invalid"))
        end

        private

        def options_mock(args)
          parser = stub(default_argv: args)
          stub(parser: parser)
        end
      end
    end
  end
end
