# frozen_string_literal: true

require "test_helper"
require "project_types/theme/models/specification_handlers/theme"

module Theme
  module Models
    module SpecificationHandlers
      class ThemeTest < MiniTest::Test
        def test_valid_directory_structure
          root = ShopifyCLI::ROOT + "/test/fixtures/theme"
          theme_directory = Theme.new(root)
          assert theme_directory.valid?
        end

        def test_missing_folders
          root = ShopifyCLI::ROOT + "/test/fixtures/theme_with_missing_folders"
          theme_directory = Theme.new(root)
          refute theme_directory.valid?
        end
      end
    end
  end
end
