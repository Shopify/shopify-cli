require 'fileutils'

module ShopifyCli
  class ShopifolkCheck
    def self.assume_shopifolk?
      ShopifyCli::ShopifolkCheck.new.assume_shopifolk?
    end

    def assume_shopifolk?
      is_shopifolk = if shopifolk_by_dev? && shopifolk_by_feature?
        true
      else
        false
      end
      is_shopifolk
    end

    def shopifolk_by_dev?
      if File.exist?('/opt/dev/bin/dev') && File.exist?('/opt/dev/.shopify-build')
        true
      else
        false
      end
    end

    def shopifolk_by_feature?
      set_shopifolk_flag_by_gcloud_config
      is_shopifolk = ShopifyCli::Feature.enabled?('shopifolk')
      if is_shopifolk
        true
      else
        false
      end
    end

    def set_shopifolk_flag_by_gcloud_config
      gcloud_account = all_configs.dig("[core]", 'account') || ""
      if gcloud_account.include?("@shopify.com")
        ShopifyCli::Feature.enable('shopifolk')
      else
        ShopifyCli::Feature.disable('shopifolk')
      end
    end

    def ini
      gcloud_config_path = '~/.config/gcloud/configurations/config_default'
      file = File.expand_path(gcloud_config_path)
      @ini ||= CLI::Kit::Ini
        .new(file, default_section: "[core]", convert_types: false)
        .tap(&:parse)
    end

    def all_configs
      ini.ini
    end
  end
end
