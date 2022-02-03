# frozen_string_literal: true
require "test_helper"

module ShopifyCLI
  class EnvironmentTest < MiniTest::Test
    include TestHelpers::FakeFS

    def test_use_local_partners_instance_returns_true_when_the_env_variable_is_set
      # Given
      env_variables = {
        Constants::EnvironmentVariables::LOCAL_PARTNERS.to_s => "1",
      }

      # When
      got = Environment.use_local_partners_instance?(env_variables: env_variables)

      # Then
      assert got
    end

    def test_auth_token_returns_the_right_value
      # Given
      env_variables = {
        Constants::EnvironmentVariables::AUTH_TOKEN.to_s => "token",
      }

      # When
      got = Environment.auth_token(env_variables: env_variables)

      # Then
      assert_equal "token", got
    end

    def test_use_local_partners_instance_returns_false_when_the_env_variable_is_not_set
      # Given/When
      got = Environment.use_local_partners_instance?(env_variables: {})

      # Then
      refute got
    end

    def test_use_spin_returns_true_when_the_partners_env_variable_is_set
      # Given
      env_variables = {
        Constants::EnvironmentVariables::SPIN_PARTNERS.to_s => "1",
      }

      # When
      got = Environment.use_spin?(env_variables: env_variables)

      # Then
      assert got
    end

    def test_use_spin_returns_false_when_the_partners_env_variable_is_set
      # When
      got = Environment.use_spin?(env_variables: {})

      # Then
      refute got
    end

    def test_partners_domain_returns_the_right_value_when_local_instance
      # Given
      env_variables = {
        Constants::EnvironmentVariables::LOCAL_PARTNERS.to_s => "1",
      }

      # When
      got = Environment.partners_domain(env_variables: env_variables)

      # Then
      assert_equal "partners.myshopify.io", got
    end

    def test_partners_domain_uses_spin
      # Given
      Environment.stubs(spin_url: "some.fqdn.com")
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => "1",
      }

      # When
      got = Environment.partners_domain(env_variables: env_variables)

      # Then
      assert_equal "partners.some.fqdn.com", got
    end

    def test_partners_domain_returns_the_right_value_when_production_instance
      # Given/When
      got = Environment.partners_domain(env_variables: {})

      # Then
      assert_equal "partners.shopify.com", got
    end

    def test_spin_url_is_nil_when_not_using_spin
      assert_nil(Environment.spin_url)
    end

    def test_spin_url_reads_from_fqdn_file
      FileUtils.mkdir_p(File.dirname(Constants::Paths::SPIN_FQDN))
      File.write(Constants::Paths::SPIN_FQDN, "some.fqdn.com")

      got = Environment.spin_url

      assert_equal "some.fqdn.com", got
    end

    def test_spin_url_is_nil_when_file_does_not_exist
      got = Environment.spin_url

      assert_nil got
    end

    def test_use_spin_is_true
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => "1",
      }

      got = Environment.use_spin?(env_variables: env_variables)

      assert got
    end

    def test_use_spin_is_false
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => nil,
      }

      got = Environment.use_spin?(env_variables: env_variables)

      refute got
    end

    def test_env_variable_truthy
      Environment::TRUTHY_ENV_VARIABLE_VALUES.each do |value|
        assert Environment.env_variable_truthy?("TEST", env_variables: { "TEST" => value })
      end
      refute Environment.env_variable_truthy?("TEST", env_variables: {})
      refute Environment.env_variable_truthy?("TEST", env_variables: { "TEST" => "0" })
    end
  end
end
