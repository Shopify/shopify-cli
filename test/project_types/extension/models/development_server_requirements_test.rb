require "test_helper"

module Extension
  module Models
    class DevelopmentServerRequirementsTest < MiniTest::Test
      CONDITIONALLY_SUPPORTED_TYPES = [
        "checkout_post_purchase",
        "checkout_ui_extension",
        "product_subscription",
        "web_pixel_extension",
        "pos_ui_extension",
      ]

      def setup
        ShopifyCLI::ProjectType.load_type(:extension)
        super
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

      def test_emits_debug_message_when_binary_missing
        Extension::Models::DevelopmentServerRequirements.stubs(:binary_installed?).returns(false)
        Extension::Models::DevelopmentServerRequirements.stubs(:beta_enabled?).returns(true)
        ShopifyCLI::Context.any_instance
          .expects(:puts)
          .with(ShopifyCLI::Context.message("errors.development_server_binary_not_found.message"))

        refute Extension::Models::DevelopmentServerRequirements.supported?("checkout_ui_extension")
      end
    end
  end
end
