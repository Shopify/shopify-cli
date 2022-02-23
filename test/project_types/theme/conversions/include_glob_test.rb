# frozen_string_literal: true

require "project_types/theme/test_helper"
require "project_types/theme/conversions/include_glob"

module Theme
  module Conversions
    class IncludeGlobTest < MiniTest::Test
      def test_options
        assert(%w(-o --only), Conversions::IncludeGlob.options)
      end
    end
  end
end
