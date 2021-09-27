require "test_helper"

module ShopifyCli
  module Migrator
    module Migrations
      module MigrationHelper
        def require_migration(path)
          migration_name = File.basename(path).gsub("_test.rb", "")
          require("shopify_cli/migrator/migrations/#{migration_name}")
        end
      end
    end
  end
end
