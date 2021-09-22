# frozen_string_literal: true
require "test_helper"

module Extension
  module Models
    class RegistrationTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_valid_title_returns_true_for_valid_title
        assert Models::Registration.valid_title?("A title")
      end

      def test_valid_title_returns_false_for_missing_title
        refute Models::Registration.valid_title?(nil)
        refute Models::Registration.valid_title?("")
        refute Models::Registration.valid_title?("  ")
      end

      def test_valid_title_returns_false_when_title_too_long
        refute Models::Registration.valid_title?(
          Array.new(Registration::MAX_TITLE_LENGTH + 1, "a").join
        )
      end
    end
  end
end
