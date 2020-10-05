require 'fileutils'

module ShopifyCli
  class ShopifolkCheck
    GCLOUD_CONFIG_PATH = '~/.config/gcloud/configurations/config_default'
    def self.assume_shopifolk?
      ShopifyCli::ShopifolkCheck.new.assume_shopifolk?
    end

    def assume_shopifolk?
      set_shopifolk_feature_by_gcloud_config
      shopifolk_by_dev? && shopifolk_by_feature?
    end

    def shopifolk_by_dev?
      File.exist?('/opt/dev/bin/dev') && File.exist?('/opt/dev/.shopify-build')
    end

    def shopifolk_by_feature?
      is_shopifolk = ShopifyCli::Feature.enabled?('shopifolk')
      if is_shopifolk
        true
      else
        false
      end
    end

    def set_shopifolk_feature_by_gcloud_config
      gcloud_account = ini.dig("[core]", 'account') || ""
      if gcloud_account.include?("@shopify.com")
        ShopifyCli::Feature.enable('shopifolk')
      else
        ShopifyCli::Feature.disable('shopifolk')
      end
    end

    def ini
      file = File.expand_path(GCLOUD_CONFIG_PATH)
      @ini ||= CLI::Kit::Ini
        .new(file, default_section: "[core]", convert_types: false)
        .tap(&:parse)
      @ini.ini
    end
  end
end
