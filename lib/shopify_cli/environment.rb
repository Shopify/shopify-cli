require "semantic/semantic"

module ShopifyCLI
  # The environment module provides an interface to get information from
  # the environment in which the CLI runs
  module Environment
    TRUTHY_ENV_VARIABLE_VALUES = ["1", "true", "TRUE", "yes", "YES"]

    def self.ruby_version(context: Context.new)
      out, err, stat = context.capture3('ruby -e "puts RUBY_VERSION"')
      raise ShopifyCLI::Abort, err unless stat.success?
      out = out.gsub('"', "")
      ::Semantic::Version.new(out.chomp)
    end

    def self.node_version(context: Context.new)
      out, err, stat = context.capture3("node", "--version")
      raise ShopifyCLI::Abort, err unless stat.success?
      out = out.gsub("v", "")
      ::Semantic::Version.new(out.chomp)
    end

    def self.interactive=(interactive)
      @interactive = interactive
    end

    def self.interactive?(env_variables: ENV)
      if env_variables.key?(Constants::EnvironmentVariables::TTY)
        env_variable_truthy?(
          Constants::EnvironmentVariables::TTY,
          env_variables: env_variables
        )
      else
        @interactive ||= STDIN.tty?
      end
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

    def self.partners_domain(env_variables: ENV)
      if use_local_partners_instance?(env_variables: env_variables)
        "partners.myshopify.io"
      elsif use_spin?(env_variables: env_variables)
        "partners.#{spin_url(env_variables: env_variables)}"
      else
        "partners.shopify.com"
      end
    end

    def self.use_spin?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::SPIN,
        env_variables: env_variables
      ) || env_variable_truthy?(
        Constants::EnvironmentVariables::SPIN_PARTNERS,
        env_variables: env_variables
      )
    end

    def self.infer_spin?(env_variables: ENV)
      env_variable_truthy?(
        Constants::EnvironmentVariables::INFER_SPIN,
        env_variables: env_variables
      )
    end

    def self.spin_url(env_variables: ENV)
      if infer_spin?(env_variables: env_variables)
        # TODO: Remove version check and delete spin-legacy branch
        #  once spin2 becomes the installed "spin" binary by default
        instances = JSON.parse(%x(exe/spin list --json --output created,fqdn))

        last_created_instance = instances.sort do |instance_a, instance_b|
          DateTime.parse(instance_b["created"]) <=> DateTime.parse(instance_a["created"]) 
        end.first

        last_created_instance["fqdn"]
      else
        raise ShopifyCLI:: Abort, "SPIN_INSTANCE must be specified" unless ENV.key?("SPIN_INSTANCE")
        %x(spin show -o fqdn 2> /dev/null).strip
      end
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
      env_value = env_variables[Constants::EnvironmentVariables::SPIN_WORKSPACE]
      return env_value unless env_value.nil?

      if env_value.nil?
        raise "No value set for #{Constants::EnvironmentVariables::SPIN_WORKSPACE}"
      end
    end

    def self.spin_namespace(env_variables: ENV)
      env_value = env_variables[Constants::EnvironmentVariables::SPIN_NAMESPACE]
      return env_value unless env_value.nil?

      if env_value.nil?
        raise "No value set for #{Constants::EnvironmentVariables::SPIN_NAMESPACE}"
      end
    end

    def self.spin_host(env_variables: ENV)
      env_variables[Constants::EnvironmentVariables::SPIN_HOST] || "us.spin.dev"
    end
  end
end
