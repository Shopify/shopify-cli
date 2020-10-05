require 'fileutils'

module ShopifyCli
  ##
  # ShopifyCli::Shopifolk contains the logic to determine if the user appears to be a Shopify employee
  #
  # The Shopifolk Feature flag will persist between runs so if the flag is enabled or disabled,
  # it will still be in that same state until the next class invocation.
  class Shopifolk
    GCLOUD_CONFIG_PATH = '~/.config/gcloud/configurations/config_default'
    SECTION = 'core'
    FEATURE_NAME = 'shopifolk'
    def self.check
      ##
      # will return if the user appears to be a Shopify employee, based on several heuristics
      #
      # #### Returns
      #
      # * `is_shopifolk` - returns true if the user is a Shopify Employee
      #
      # #### Example
      #
      #     ShopifyCli::Shopifolk.check
      #
      ShopifyCli::Shopifolk.new.shopifolk?
    end

    def shopifolk?(gcloud_config_path = GCLOUD_CONFIG_PATH)
      ##
      # will return if the user is a Shopify employee
      #
      # #### Returns
      #
      # * `is_shopifolk` - returns true if the user has `dev` installed and
      # a valid google cloud config file with email ending in "@shopify.com"
      #
      @gcloud_config_path = gcloud_config_path
      shopifolk_feature_by_gcloud_config
      shopifolk_by_dev? && shopifolk_by_feature?
    end

    private

    def shopifolk_by_dev?
      File.exist?('/opt/dev/bin/dev') && File.exist?('/opt/dev/.shopify-build')
    end

    def shopifolk_by_feature?
      ShopifyCli::Feature.enabled?(FEATURE_NAME)
    end

    def shopifolk_feature_by_gcloud_config
      gcloud_account = ini.dig("[#{SECTION}]", 'account') || ""
      if gcloud_account.include?("@shopify.com")
        ShopifyCli::Feature.enable(FEATURE_NAME)
      else
        ShopifyCli::Feature.disable(FEATURE_NAME)
      end
    end

    def ini
      file = File.expand_path(@gcloud_config_path)
      @ini ||= CLI::Kit::Ini
        .new(file, default_section: "[#{SECTION}]", convert_types: false)
        .tap(&:parse).ini
    end
  end
end
