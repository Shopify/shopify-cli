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
          @theme_specification_handler.root_folders = Theme::REQUIRED_ROOT_FOLDERS + Theme::OPTIONAL_ROOT_FOLDERS
          @theme_specification_handler.templates_folders = Theme::REQUIRED_TEMPLATES_FOLDERS
          @theme_specification_handler.validate
          assert @theme_specification_handler.valid?
        end

        def test_required_folders_missing
          @theme_specification_handler.root_folders = Theme::REQUIRED_ROOT_FOLDERS.first(2)
          @theme_specification_handler.templates_folders = []
          @theme_specification_handler.validate
          refute @theme_specification_handler.valid?
          assert_equal Theme::REQUIRED_ROOT_FOLDERS.last(2), @theme_specification_handler.missing_root_folders
        end

        def test_superfluous_folders_present
          superfluous_folders = ["foo/", "bar/"]
          @theme_specification_handler.root_folders = Theme::REQUIRED_ROOT_FOLDERS + superfluous_folders
          @theme_specification_handler.templates_folders = Theme::REQUIRED_TEMPLATES_FOLDERS + superfluous_folders
          @theme_specification_handler.validate
          assert_empty @theme_specification_handler.missing_root_folders
          assert_equal superfluous_folders, @theme_specification_handler.superfluous_root_folders
        end
      end
    end
  end
end
