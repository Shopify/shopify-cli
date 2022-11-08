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
          @theme_specification_handler.folders = Theme::REQUIRED_FOLDERS + Theme::OPTIONAL_FOLDERS
          assert @theme_specification_handler.valid?
        end

        def test_required_folders_missing
          @theme_specification_handler.folders = Theme::REQUIRED_FOLDERS.first(2)
          refute @theme_specification_handler.valid?
          assert_equal Theme::REQUIRED_FOLDERS.last(3), @theme_specification_handler.missing_folders
        end

        def test_superfluous_folders_present
          superfluous_folders = ["foo/", "bar/"]
          @theme_specification_handler.folders = Theme::REQUIRED_FOLDERS + superfluous_folders
          refute @theme_specification_handler.valid?
          assert_empty @theme_specification_handler.missing_folders
          assert_equal superfluous_folders, @theme_specification_handler.superfluous_folders
        end
      end
    end
  end
end
