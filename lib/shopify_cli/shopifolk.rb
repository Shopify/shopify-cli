module ShopifyCLI
  ##
  # ShopifyCLI::Shopifolk contains the logic to determine if the user appears to be a Shopify staff
  #
  # The Shopifolk Feature flag will persist between runs so if the flag is enabled or disabled,
  # it will still be in that same state until the next class invocation.
  class Shopifolk
    GCLOUD_CONFIG_FILE = File.expand_path("~/.config/gcloud/configurations/config_default")
    DEV_PATH = "/opt/dev"
    SECTION = "core"
    FEATURE_NAME = "shopifolk"

    class << self
      ##
      # will return if the user appears to be a Shopify employee, based on several heuristics
      #
      # #### Returns
      #
      # * `is_shopifolk` - returns true if the user is a Shopify Employee
      #
      # #### Example
      #
      #     ShopifyCLI::Shopifolk.check
      #
      def check
        ShopifyCLI::Shopifolk.new.shopifolk?
      end

      def act_as_shopify_organization
        DB.set(acting_as_shopify_organization: true)
      end

      def acting_as_shopify_organization?
        !!(DB.get(:acting_as_shopify_organization) ||
        (Project.has_current? && Project.current.config["shopify_organization"]))
      end

      def reset
        DB.del(:acting_as_shopify_organization)
      end
    end

    ##
    # will return if the user is a Shopify employee
    #
    # #### Returns
    #
    # * `is_shopifolk` - returns true if the user has `dev` installed and
    # a valid google cloud config file with email ending in "@shopify.com"
    #
    def shopifolk?
      return true if Feature.enabled?(FEATURE_NAME)

      if shopifolk_by_gcloud? && shopifolk_by_dev?
        ShopifyCLI::Feature.enable(FEATURE_NAME)
        true
      else
        ShopifyCLI::Feature.disable(FEATURE_NAME)
        false
      end
    end

    private

    def shopifolk_by_gcloud?
      ini&.dig("[#{SECTION}]", "account")&.match?(/@shopify.com\z/)
    end

    def shopifolk_by_dev?
      File.exist?("#{DEV_PATH}/bin/dev") && File.exist?("#{DEV_PATH}/.shopify-build")
    end

    def ini
      @ini ||= if File.exist?(GCLOUD_CONFIG_FILE)
        CLI::Kit::Ini
          .new(GCLOUD_CONFIG_FILE, default_section: "[#{SECTION}]", convert_types: false)
          .tap(&:parse).ini
      end
    end
  end
end
