# frozen_string_literal: true

module ShopifyCLI
  module Migrator
    module Migrations
      # This migration moves the flag to enable/disable analytics from the
      # configuration store to db
      class AnalyticsEnabledToDb
        def self.run
          # value = ShopifyCli::Config.get_bool("analytics", "enabled", default: false)
          # ShopifyCli::DB.set(ShopifyCli::Constants::StoreKeys::ANALYTICS_ENABLED => value)
        end
      end
    end
  end
end
