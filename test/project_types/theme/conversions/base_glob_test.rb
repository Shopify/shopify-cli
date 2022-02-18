# frozen_string_literal: true

require "project_types/theme/test_helper"
require "project_types/theme/conversions/base_glob"

module Theme
  module Conversions
    class BaseGlobTest < MiniTest::Test
      def test_register
        parser = mock
        parser.expects(:accept).with(Conversions::BaseGlob)

        Conversions::BaseGlob.register(parser)
      end

      def test_convert_with_only
        Conversions::BaseGlob.stubs(:options).returns(%w(-o --only))

        actual_params = Conversions::BaseGlob.convert(parser)
        expected_params = [
          "layout/password.liquid",
          "layout/theme.liquid",
        ]

        assert_equal(expected_params, actual_params)
      end

      def test_convert_with_ignore
        Conversions::BaseGlob.stubs(:options).returns(%w(-x --ignore))

        actual_params = Conversions::BaseGlob.convert(parser)
        expected_params = [
          "sections/announcement-bar.liquid",
          "sections/contact-form.liquid",
        ]

        assert_equal(expected_params, actual_params)
      end

      def test_convert_when_options_is_not_defined
        error = assert_raises(RuntimeError) { Conversions::BaseGlob.convert(parser) }
        assert_match(/`Class#options` must be defined/, error.message)
      end

      private

      def parser
        stub(default_argv: argv, top: top)
      end

      def argv
        [
          "theme",
          "push",
          "-d",
          "--only",
          "layout/password.liquid",
          "layout/theme.liquid",
          "--ignore",
          "sections/announcement-bar.liquid",
          "sections/contact-form.liquid",
        ]
      end

      def top
        stub(list: [
          stub(short: ["-h"], long: ["--help"], arg: nil),
          stub(short: ["-n"], long: ["--nodelete"], arg: nil),
          stub(short: ["-i"], long: ["--themeid"], arg: "=ID"),
          stub(short: ["-t"], long: ["--theme"], arg: "=NAME_OR_ID"),
          stub(short: ["-l"], long: ["--live"], arg: nil),
          stub(short: ["-d"], long: ["--development"], arg: nil),
          stub(short: ["-o"], long: ["--only"], arg: "=PATTERN"),
          stub(short: ["-x"], long: ["--ignore"], arg: "=PATTERN"),
        ])
      end
    end
  end
end
