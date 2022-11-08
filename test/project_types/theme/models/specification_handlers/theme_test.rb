# frozen_string_literal: true

require "test_helper"
require "project_types/theme/models/specification_handlers/theme"

module Theme
  module Models
    module SpecificationHandlers
      class ThemeTest < MiniTest::Test
        def setup
          super
          @theme_directory = Theme.new(nil)
        end

        def test_valid_directory_structure
          @theme_directory.folders = Theme::REQUIRED_FOLDERS
          assert @theme_directory.valid?
        end

        def test_missing_folders
          @theme_directory.folders = Theme::REQUIRED_FOLDERS.first(2)
          refute @theme_directory.valid?
          assert_equal Theme::REQUIRED_FOLDERS.last(3), @theme_directory.missing_folders
        end

        def test_additional_folders
          additional_folders = ["webpack/", "foobar/"]
          @theme_directory.folders = Theme::REQUIRED_FOLDERS + additional_folders
          assert @theme_directory.valid?
          assert_empty @theme_directory.missing_folders
        end
      end
    end
  end
end
