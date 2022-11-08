# frozen_string_literal: true

require "test_helper"
require "project_types/theme/models/specification_handlers/theme"

module Theme
  module Models
    module SpecificationHandlers
      class ThemeTest < MiniTest::Test
        def setup
          super
          @theme_specification_handler = Theme.new(nil)
        end

        def test_valid_directory_structure
          @theme_specification_handler.folders = Theme::REQUIRED_FOLDERS
          assert @theme_specification_handler.valid?
        end

        def test_missing_folders
          @theme_specification_handler.folders = Theme::REQUIRED_FOLDERS.first(2)
          refute @theme_specification_handler.valid?
          assert_equal Theme::REQUIRED_FOLDERS.last(3), @theme_specification_handler.missing_folders
        end

        def test_additional_folders
          additional_folders = ["webpack/", "foobar/"]
          @theme_specification_handler.folders = Theme::REQUIRED_FOLDERS + additional_folders
          assert @theme_specification_handler.valid?
          assert_empty @theme_specification_handler.missing_folders
        end
      end
    end
  end
end
