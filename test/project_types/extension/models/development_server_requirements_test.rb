require "test_helper"

module Extension
  module Models
    class DevelopmentServerRequirementsTest < MiniTest::Test
      UNCONDITIONALLY_SUPPORTED_TYPES = [
        "checkout_ui_extension",
      ]
      CONDITIONALLY_SUPPORTED_TYPES = [
        "checkout_post_purchase",
        "product_subscription",
      ]

      def setup
        ShopifyCLI::ProjectType.load_type(:extension)
        super
      end

      def test_unconditionally_supported_types_beta_enabled
        Extension::Models::DevelopmentServerRequirements.stubs(:binary_installed?).returns(true)
        Extension::Models::DevelopmentServerRequirements.stubs(:beta_enabled?).returns(true)

        UNCONDITIONALLY_SUPPORTED_TYPES.each do |type|
          assert Extension::Models::DevelopmentServerRequirements.supported?(type)
        end
      end

      def test_unconditionally_supported_types_beta_disabled
        Extension::Models::DevelopmentServerRequirements.stubs(:binary_installed?).returns(true)
        Extension::Models::DevelopmentServerRequirements.stubs(:beta_enabled?).returns(false)

        UNCONDITIONALLY_SUPPORTED_TYPES.each do |type|
          assert Extension::Models::DevelopmentServerRequirements.supported?(type)
        end
      end

      def test_unconditionally_supported_types_beta_enabled_binary_missing
        Extension::Models::DevelopmentServerRequirements.stubs(:binary_installed?).returns(false)
        Extension::Models::DevelopmentServerRequirements.stubs(:beta_enabled?).returns(true)

        UNCONDITIONALLY_SUPPORTED_TYPES.each do |type|
          refute Extension::Models::DevelopmentServerRequirements.supported?(type)
        end
      end

      def test_conditionally_supported_types_beta_enabled
        Extension::Models::DevelopmentServerRequirements.stubs(:binary_installed?).returns(true)
        Extension::Models::DevelopmentServerRequirements.stubs(:beta_enabled?).returns(true)

        CONDITIONALLY_SUPPORTED_TYPES.each do |type|
          assert Extension::Models::DevelopmentServerRequirements.supported?(type)
        end
      end

      def test_conditionally_supported_types_beta_disabled
        Extension::Models::DevelopmentServerRequirements.stubs(:binary_installed?).returns(true)
        Extension::Models::DevelopmentServerRequirements.stubs(:beta_enabled?).returns(false)

        CONDITIONALLY_SUPPORTED_TYPES.each do |type|
          refute Extension::Models::DevelopmentServerRequirements.supported?(type)
        end
      end

      def test_conditionally_supported_types_beta_enabled_binary_missing
        Extension::Models::DevelopmentServerRequirements.stubs(:binary_installed?).returns(false)
        Extension::Models::DevelopmentServerRequirements.stubs(:beta_enabled?).returns(true)

        CONDITIONALLY_SUPPORTED_TYPES.each do |type|
          refute Extension::Models::DevelopmentServerRequirements.supported?(type)
        end
      end

      def test_unknown_type
        Extension::Models::DevelopmentServerRequirements.stubs(:binary_installed?).returns(true)
        Extension::Models::DevelopmentServerRequirements.stubs(:beta_enabled?).returns(true)

        refute DevelopmentServerRequirements.supported?("unknown")
      end
    end
  end
end
