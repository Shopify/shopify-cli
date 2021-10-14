# frozen_string_literal: true

module ShopifyCLI
  module Migrator
    module Migrations
      # Before this migration, users configured automatic usage and error
      # reporting independenty. We changed it to be a single configuration
      # in the environment's configuration and therefore we need a migration
      # to merge the configurations.
      class MergeReportingConfiguration
        def self.run
          analytics_enabled = ShopifyCLI::Config.get_bool(
            Constants::Config::Sections::Analytics::NAME,
            Constants::Config::Sections::Analytics::Fields::ENABLED,
            default: false
          )
          error_reporting_enabled = ShopifyCLI::Config.get_bool(
            "error-tracking",
            "automatic-reporting",
            default: false
          )
          # Because we are merging configuration options, both need
          # to be true to for the new flag to be true. Otherwise,
          # we delete them and let the CLI prompt the user again.
          should_merge_be_true = analytics_enabled && error_reporting_enabled

          unless should_merge_be_true
            ShopifyCLI::Config.unset(
              Constants::Config::Sections::Analytics::NAME,
              Constants::Config::Sections::Analytics::Fields::ENABLED
            )
            ShopifyCLI::Config.unset(
              "error-tracking",
              "automatic-reporting"
            )
          end
        end
      end
    end
  end
end
