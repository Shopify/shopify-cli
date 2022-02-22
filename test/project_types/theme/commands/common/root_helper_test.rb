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

        def test_root_value_when_root_appears_after_an_option_without_arguments
          options = options_mock([
            "theme",
            "pull",
            "-d",
            "dir",
            "-x",
            "dir",
            "-o",
            "dir",
          ])

          assert_equal("dir", root_value(options, "pull"))
        end

        def test_root_value_when_root_appears_after_an_option_with_arguments
          options = options_mock([
            "theme",
            "pull",
            "-d",
            "--theme",
            "1",
            "dir",
            "-x",
            "sections/announcement-bar.liquid",
            "-x",
            "sections/apps.liquid",
            "-o",
            "layout/*",
            "-o",
            "other",
          ])

          assert_equal("dir", root_value(options, "pull"))
        end

        def test_root_value_when_root_appears_after_an_option_with_a_list_of_arguments
          options = options_mock([
            "theme",
            "pull",
            "-d",
            "-x",
            "sections/announcement-bar.liquid",
            "sections/announcement-bar.liquid",
            "sections/announcement-bar.liquid",
            "-o",
            "layout/*",
            "--theme",
            "1",
            "dir",
            "-o",
            "other",
          ])

          assert_equal("dir", root_value(options, "pull"))
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
          top = stub(list: [
            stub(short: ["-h"], long: ["--help"], arg: nil),
            stub(short: ["-n"], long: ["--nodelete"], arg: nil),
            stub(short: ["-i"], long: ["--themeid"], arg: "=ID"),
            stub(short: ["-t"], long: ["--theme"], arg: "=NAME_OR_ID"),
            stub(short: ["-l"], long: ["--live"], arg: nil),
            stub(short: ["-d"], long: ["--development"], arg: nil),
            stub(short: ["-o"], long: ["--only"], arg: "=PATTERN"),
            stub(short: ["-x"], long: ["--ignore"], arg: "=PATTERN"),
          ])

          parser = stub(default_argv: args, top: top)
          stub(parser: parser)
        end
      end
    end
  end
end
