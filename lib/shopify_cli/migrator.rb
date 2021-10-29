# frozen_string_literal: true
require "date"

module ShopifyCLI
  module Migrator
    autoload :Migration, "shopify_cli/migrator/migration"

    def self.migrate(
      migrations_directory: File.expand_path("migrator/migrations", __dir__)
    )
      baseline_date = last_migration_date
      unless baseline_date.nil?
        migrations(migrations_directory: migrations_directory)
          .select do |m|
            m.date > baseline_date.to_i
          end
          .each(&:run)
      end

      store_last_migration_date
    end

    def self.store_last_migration_date
      ShopifyCLI::DB.set(ShopifyCLI::Constants::StoreKeys::LAST_MIGRATION_DATE => Time.now.to_i)
    end

    def self.last_migration_date
      ShopifyCLI::DB.get(ShopifyCLI::Constants::StoreKeys::LAST_MIGRATION_DATE)
    end

    def self.migrations(migrations_directory:)
      Dir.glob(File.join(migrations_directory, "*.rb")).map do |file_path|
        file_name = File.basename(file_path).gsub(".rb", "")
        file_name_components = file_name.split("_")
        date_timestamp = file_name_components[0].to_i
        migration_name = file_name_components.drop(1).join("_")

        Migrator::Migration.new(
          name: migration_name,
          date: Time.at(date_timestamp).to_i,
          path: file_path
        )
      end
    end
  end
end
