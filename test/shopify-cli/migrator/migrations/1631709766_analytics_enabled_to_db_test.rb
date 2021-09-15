require "test_helper"
require_relative "./migration_helper"

module ShopifyCli
  module Migrator
    module Migrations
      class AnalyticsEnabledToDbTest < MiniTest::Test
        extend MigrationHelper

        require_migration(__FILE__)

        def test_run_migrates_the_data_from_config
          # Given
          ShopifyCli::Config
            .expects(:get_bool)
            .with("analytics", "enabled", default: false)
            .returns(true)

          ShopifyCli::DB
            .expects(:set)
            .with(ShopifyCli::Constants::StoreKeys::ANALYTICS_ENABLED => true)

          # When/then
          AnalyticsEnabledToDb.run
        end
      end
    end
  end
end
