require 'fileutils'

module ShopifyCli
  ##
  # ShopifyCli::Shopifolk contains the logic to determine if the user appears to be a Shopify employee
  #
  # The Shopifolk Feature flag will persist between runs so if the flag is enabled or disabled,
  # it will still be in that same state until the next class invocation.
  class Shopifolk
    GCLOUD_CONFIG_PATH = '~/.config/gcloud/configurations/config_default'
    DEV_PATH = '/opt/dev'
    SECTION = 'core'
    GCLOUD_FEATURE_NAME = 'gcloud_shopifolk'
    DEV_FEATURE_NAME = 'dev_shopifolk'
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

    def shopifolk?(gcloud_config_path = GCLOUD_CONFIG_PATH, dev_path = DEV_PATH)
      ##
      # will return if the user is a Shopify employee
      #
      # #### Returns
      #
      # * `is_shopifolk` - returns true if the user has `dev` installed and
      # a valid google cloud config file with email ending in "@shopify.com"
      #
      @gcloud_config_path = gcloud_config_path
      @dev_path = dev_path
      shopifolk_feature_by_gcloud_config
      shopifolk_feature_by_dev
      shopifolk_by_dev? && shopifolk_by_gcloud?
    end

    private

    def shopifolk_by_dev?
      ShopifyCli::Feature.enabled?(DEV_FEATURE_NAME)
    end

    def shopifolk_by_gcloud?
      ShopifyCli::Feature.enabled?(GCLOUD_FEATURE_NAME)
    end

    def shopifolk_feature_by_gcloud_config
      if File.exist?(File.expand_path(@gcloud_config_path))
        gcloud_account = ini.dig("[#{SECTION}]", 'account') || ""
      end
      if gcloud_account&.include?("@shopify.com")
        ShopifyCli::Feature.enable(GCLOUD_FEATURE_NAME)
      else
        ShopifyCli::Feature.disable(GCLOUD_FEATURE_NAME)
      end
    end

    def shopifolk_feature_by_dev
      if File.exist?("#{@dev_path}/bin/dev") && File.exist?("#{@dev_path}/.shopify-build")
        ShopifyCli::Feature.enable(DEV_FEATURE_NAME)
      else
        ShopifyCli::Feature.disable(DEV_FEATURE_NAME)
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
