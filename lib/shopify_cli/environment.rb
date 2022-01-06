module ShopifyCLI
  # The environment module provides an interface to get information from
  # the environment in which the CLI runs
  module Environment
    TRUTHY_ENV_VARIABLE_VALUES = ["1", "true", "TRUE", "yes", "YES"]

    def self.interactive=(interactive)
      @interactive = interactive
    end

    def self.interactive?
      @interactive ||= STDIN.tty?
    end

    def self.development?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::DEVELOPMENT,
        env_variables: env_variables
      )
    end

    def self.use_local_partners_instance?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::LOCAL_PARTNERS,
        env_variables: env_variables
      )
    end

    def self.print_stacktrace?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::STACKTRACE,
        env_variables: env_variables
      ) || development?(env_variables: env_variables)
    end

    def self.test?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::TEST,
        env_variables: env_variables
      )
    end

    def self.acceptance_test?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::ACCEPTANCE_TEST,
        env_variables: env_variables
      )
    end

    def self.print_backtrace?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::BACKTRACE,
        env_variables: env_variables
      )
    end

    def self.use_spin_partners_instance?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::SPIN_PARTNERS,
        env_variables: env_variables
      )
    end

    def self.partners_domain(env_variables: ENV)
      if use_local_partners_instance?(env_variables: env_variables)
        "partners.myshopify.io"
      elsif use_spin_partners_instance?(env_variables: env_variables)
        "partners.#{spin_url(env_variables: env_variables)}"
      else
        "partners.shopify.com"
      end
    end

    def self.use_spin?(env_variables: ENV)
      !env_variables[Constants::EnvironmentVariables::SPIN_WORKSPACE].nil? &&
        !env_variables[Constants::EnvironmentVariables::SPIN_NAMESPACE].nil?
    end

    def self.spin_url(env_variables: ENV)
      spin_workspace = spin_workspace(env_variables: env_variables)
      spin_namespace = spin_namespace(env_variables: env_variables)
      spin_host = spin_host(env_variables: env_variables)
      "#{spin_workspace}.#{spin_namespace}.#{spin_host}"
    end

    def self.send_monorail_events?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::MONORAIL_REAL_EVENTS,
        env_variables: env_variables
      )
    end

    def self.auth_token(env_variables: ENV)
      env_variables[Constants::EnvironmentVariables::AUTH_TOKEN]
    end

    def self.env_variable_truthy?(variable_name, env_variables: ENV)
      TRUTHY_ENV_VARIABLE_VALUES.include?(env_variables[variable_name.to_s])
    end

    def self.spin_workspace(env_variables: ENV)
      env_variables[Constants::EnvironmentVariables::SPIN_WORKSPACE]
    end

    def self.spin_namespace(env_variables: ENV)
      env_variables[Constants::EnvironmentVariables::SPIN_NAMESPACE]
    end

    def self.spin_host(env_variables: ENV)
      env_variables[Constants::EnvironmentVariables::SPIN_HOST] || "us.spin.dev"
    end
  end
end
