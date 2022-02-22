# frozen_string_literal: true

require "project_types/theme/test_helper"
require "project_types/theme/conversions/ignore_glob"

module Theme
  module Conversions
    class IgnoreGlobTest < MiniTest::Test
      def test_options
        assert(%w(-x --ignore), Conversions::IgnoreGlob.options)
      end
    end
  end
end
