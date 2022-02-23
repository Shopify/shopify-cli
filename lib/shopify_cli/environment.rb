require "semantic/semantic"

module ShopifyCLI
  # The environment module provides an interface to get information from
  # the environment in which the CLI runs
  module Environment
    TRUTHY_ENV_VARIABLE_VALUES = ["1", "true", "TRUE", "yes", "YES"]
    SPIN_OVERRIDE_ENV_NAMES = [
      Constants::EnvironmentVariables::SPIN_WORKSPACE,
      Constants::EnvironmentVariables::SPIN_NAMESPACE,
      Constants::EnvironmentVariables::SPIN_HOST,
    ]

    def self.ruby_version(context: Context.new)
      out, err, stat = context.capture3("ruby", "-v")
      raise ShopifyCLI::Abort, err unless stat.success?
      version = out.match(/ruby (\d+\.\d+\.\d+)/)[1]
      ::Semantic::Version.new(version)
    end

    def self.node_version(context: Context.new)
      out, err, stat = context.capture3("node", "--version")
      raise ShopifyCLI::Abort, err unless stat.success?
      out = out.gsub("v", "")
      ::Semantic::Version.new(out.chomp)
    end

    def self.npm_version(context: Context.new)
      out, err, stat = context.capture3("npm", "--version")
      raise ShopifyCLI::Abort, err unless stat.success?
      ::Semantic::Version.new(out.chomp)
    end

    def self.rails_version(context: Context.new)
      output, status = context.capture2e("rails", "--version")
      unless status.success?
        context.abort(context.message("core.app.create.rails.error.install_failure", "rails"))
      end
      version = output.match(/Rails (\d+\.\d+\.\d+)/)[1]
      ::Semantic::Version.new(version)
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

    def self.spin_url_override(env_variables: ENV)
      tokens = SPIN_OVERRIDE_ENV_NAMES.map do |name|
        env_variables[name]
      end

      return if tokens.all?(&:nil?)

      if tokens.any?(&:nil?)
        raise "To manually target a spin instance, you must set #{SPIN_OVERRIDE_ENV_NAMES}"
      else
        tokens.join(".")
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

    def self.spin_url(env_variables: ENV)
      override = spin_url_override(env_variables: env_variables)
      return override unless override.nil?

      spin_response = if env_variables.key?(
        Constants::EnvironmentVariables::SPIN_INSTANCE
      )
        spin_show
      else
        spin_show(latest: true)
      end

      begin
        instance = JSON.parse(spin_response)
        raise "Missing key 'fqdn' from spin show. Actual response: #{instance}" unless instance.include?("fqdn")
        instance["fqdn"]
      rescue => e
        raise "Failed to infer spin environment from spin show response #{spin_response}: #{e}"
      end
    end

    def self.spin_show(latest: false)
      latest ? %x(spin show --latest --json) : %x(spin show --json)
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
  end
end
