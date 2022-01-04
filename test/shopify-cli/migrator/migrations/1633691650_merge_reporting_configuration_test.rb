# typed: ignore
require "test_helper"
require "shopify-cli/migrator/migrations/migration_helper"
# frozen_string_literal: true

module ShopifyCLI
  module Migrator
    module Migrations
      class MergeReportingConfigurationTest < MiniTest::Test
        include MigrationHelper

        require_migration(__FILE__)

        def test_run_when_both_options_are_true
          # Given
          ShopifyCLI::Config
            .expects(:get_bool)
            .with(
              Constants::Config::Sections::Analytics::NAME,
              Constants::Config::Sections::Analytics::Fields::ENABLED,
              default: false
            )
            .returns(true)
          ShopifyCLI::Config
            .expects(:get_bool)
            .with(
              "error-tracking",
              "automatic-reporting",
              default: false
            )
            .returns(true)
          ShopifyCLI::Config
            .expects(:unset)
            .with(
              Constants::Config::Sections::Analytics::NAME,
              Constants::Config::Sections::Analytics::Fields::ENABLED
            )
            .never
          ShopifyCLI::Config
            .expects(:unset)
            .with(
              "error-tracking",
              "automatic-reporting"
            )
            .never
          # When/Then
          MergeReportingConfiguration.run
        end

        def test_run_when_analytics_is_true_and_error_reporting_false
          # Given
          ShopifyCLI::Config
            .expects(:get_bool)
            .with(
              Constants::Config::Sections::Analytics::NAME,
              Constants::Config::Sections::Analytics::Fields::ENABLED,
              default: false
            )
            .returns(true)
          ShopifyCLI::Config
            .expects(:get_bool)
            .with(
              "error-tracking",
              "automatic-reporting",
              default: false
            )
            .returns(false)
          ShopifyCLI::Config
            .expects(:unset)
            .with(
              Constants::Config::Sections::Analytics::NAME,
              Constants::Config::Sections::Analytics::Fields::ENABLED
            )
          ShopifyCLI::Config
            .expects(:unset)
            .with(
              "error-tracking",
              "automatic-reporting"
            )
          # When/Then
          MergeReportingConfiguration.run
        end

        def test_run_when_analytics_is_false_and_error_reporting_true
          # Given
          ShopifyCLI::Config
            .expects(:get_bool)
            .with(
              Constants::Config::Sections::Analytics::NAME,
              Constants::Config::Sections::Analytics::Fields::ENABLED,
              default: false
            )
            .returns(false)
          ShopifyCLI::Config
            .expects(:get_bool)
            .with(
              "error-tracking",
              "automatic-reporting",
              default: false
            )
            .returns(true)
          ShopifyCLI::Config
            .expects(:unset)
            .with(
              Constants::Config::Sections::Analytics::NAME,
              Constants::Config::Sections::Analytics::Fields::ENABLED
            )
          ShopifyCLI::Config
            .expects(:unset)
            .with(
              "error-tracking",
              "automatic-reporting"
            )
          # When/Then
          MergeReportingConfiguration.run
        end
      end
    end
  end
end
