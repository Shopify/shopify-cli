# typed: ignore
require "test_helper"

module Extension
  module Models
    module ServerConfig
      class DevelopmentEntriesTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_entries_are_created_with_valid_attributes
          assert_nothing_raised do
            ServerConfig::DevelopmentEntries.new(main: "src/index.js")
          end
        end

        def test_invalid_entry_raises_error
          assert_raises SmartProperties::Error do
            ServerConfig::DevelopmentEntries.new(
              main: "invalid"
            )
          end
        end
      end
    end
  end
end
