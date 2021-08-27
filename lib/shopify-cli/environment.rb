module ShopifyCli
  # The environment module provides an interface to get information from
  # the environment in which the CLI runs
  module Environment
    def self.use_local_partners_instance?
      env_variable_truthy?(Constants::EnvironmentVariables::LOCAL_PARTNERS)
    end

    def self.partners_domain
      if use_local_partners_instance?
        "partners.myshopify.io"
      else
        "partners.shopify.com"
      end
    end

    def self.env_variable_truthy?(variable_name)
      ["1", "true", "TRUE", "yes", "YES"].include?(ENV[variable_name])
    end
  end
end
