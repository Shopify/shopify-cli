require "test_helper"

module ShopifyCli
  module Migrator
    class MigrationTest < MiniTest::Test
      def test_class_name_returns_the_right_value
        # Given
        subject = Migration.new(
          name: "test_migration",
          path: "/path/to/1631714803_test_migration.rb",
          date: Time.at(1631714803)
        )

        # When/then
        assert_equal "TestMigration", subject.class_name
      end
    end
  end
end
