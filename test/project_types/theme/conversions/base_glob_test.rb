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
        parser = mock
        parser.stubs(:default_argv).returns(argv)

        Conversions::BaseGlob.stubs(:options).returns(%w(-o --only))

        actual_params = Conversions::BaseGlob.convert(parser)
        expected_params = [
          "layout/password.liquid",
          "layout/theme.liquid",
        ]

        assert_equal(expected_params, actual_params)
      end

      def test_convert_with_ignore
        parser = mock
        parser.stubs(:default_argv).returns(argv)

        Conversions::BaseGlob.stubs(:options).returns(%w(-x --ignore))

        actual_params = Conversions::BaseGlob.convert(parser)
        expected_params = [
          "sections/announcement-bar.liquid",
          "sections/contact-form.liquid",
        ]

        assert_equal(expected_params, actual_params)
      end

      def test_convert_when_options_is_not_defined
        parser = mock
        parser.stubs(:default_argv).returns(argv)

        error = assert_raises(RuntimeError) { Conversions::BaseGlob.convert(parser) }
        assert_match(/`Class#options` must be defined/, error.message)
      end

      private

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
    end
  end
end
