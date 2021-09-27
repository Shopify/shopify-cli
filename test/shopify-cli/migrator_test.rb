require "test_helper"
require "fileutils"

module ShopifyCLI
  class MigratorTest < Minitest::Test
    include TestHelpers::TemporaryDirectory

    def setup
      super
      @migrations_directory = File.join(@tmp_dir, "migrations")
    end

    def test_run_when_theres_a_last_migration_date
      # Given
      time = Time.now
      ShopifyCLI::DB
        .expects(:get)
        .with(ShopifyCLI::Constants::StoreKeys::LAST_MIGRATION_DATE)
        .returns(Time.now)

      create_migrations_directory(time: time + 20)
      Migrator::Migration
        .any_instance
        .expects(:run)
        .once

      # When/then
      Migrator.migrate(
        migrations_directory: @migrations_directory,
      )
    end

    def test_run_when_neither_last_migation_nor_installation_date_are_present
      # Given
      time = Time.now
      ShopifyCLI::DB
        .expects(:get)
        .with(ShopifyCLI::Constants::StoreKeys::LAST_MIGRATION_DATE)
        .returns(nil)
      create_migrations_directory(time: time)
      Migrator::Migration
        .any_instance
        .expects(:run)
        .never

      # When/then
      Migrator.migrate(
        migrations_directory: @migrations_directory,
      )
    end

    private

    def create_migrations_directory(time:)
      FileUtils.mkdir_p(@migrations_directory)
      migration_path = File.join(@migrations_directory, "#{time.to_i}_test_migration.rb")
      FileUtils.touch(migration_path)
    end
  end
end
