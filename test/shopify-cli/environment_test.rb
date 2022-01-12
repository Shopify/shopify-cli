# frozen_string_literal: true
require "test_helper"

module ShopifyCLI
  class EnvironmentTest < MiniTest::Test
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

    def test_partners_domain_returns_the_right_value_when_spin_instance
      # Given
      env_variables = {
        Constants::EnvironmentVariables::SPIN_PARTNERS.to_s => "1",
        Constants::EnvironmentVariables::SPIN_WORKSPACE.to_s => "abcd",
        Constants::EnvironmentVariables::SPIN_NAMESPACE.to_s => "my-namespace",
        Constants::EnvironmentVariables::SPIN_HOST.to_s => "us-dev.scvm.io",
      }

      # When
      got = Environment.partners_domain(env_variables: env_variables)

      # Then
      assert_equal "partners.abcd.my-namespace.us-dev.scvm.io", got
    end

    def test_partners_domain_returns_the_right_value_when_spin_instance_no_host
      # Given
      env_variables = {
        Constants::EnvironmentVariables::SPIN_PARTNERS.to_s => "1",
        Constants::EnvironmentVariables::SPIN_WORKSPACE.to_s => "abcd",
        Constants::EnvironmentVariables::SPIN_NAMESPACE.to_s => "my-namespace",
      }

      # When
      got = Environment.partners_domain(env_variables: env_variables)

      # Then
      assert_equal "partners.abcd.my-namespace.us.spin.dev", got
    end

    def test_partners_domain_returns_the_right_value_when_production_instance
      # Given/When
      got = Environment.partners_domain

      # Then
      assert_equal "partners.shopify.com", got
    end

    def test_spin_url_returns_the_right_value
      # Given
      env_variables = {
        Constants::EnvironmentVariables::SPIN_PARTNERS.to_s => "1",
        Constants::EnvironmentVariables::SPIN_WORKSPACE.to_s => "abcd",
        Constants::EnvironmentVariables::SPIN_NAMESPACE.to_s => "my-namespace",
        Constants::EnvironmentVariables::SPIN_HOST.to_s => "us-dev.scvm.io",
      }

      # When
      got = Environment.partners_domain(env_variables: env_variables)

      # Then
      assert_equal "partners.abcd.my-namespace.us-dev.scvm.io", got
    end

    def test_spin_url_returns_the_right_value_no_host
      # Given
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => "1",
        Constants::EnvironmentVariables::SPIN_WORKSPACE.to_s => "abcd",
        Constants::EnvironmentVariables::SPIN_NAMESPACE.to_s => "my-namespace",
      }

      # When
      got = Environment.partners_domain(env_variables: env_variables)

      # Then
      assert_equal "partners.abcd.my-namespace.us.spin.dev", got
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

    def test_infer_spin_is_false
      env_variables = {
        Constants::EnvironmentVariables::INFER_SPIN.to_s => nil,
      }

      got = Environment.infer_spin?(env_variables: env_variables)

      refute got
    end

    def test_infer_spin_is_true
      env_variables = {
        Constants::EnvironmentVariables::INFER_SPIN.to_s => "1",
      }

      got = Environment.infer_spin?(env_variables: env_variables)

      assert got
    end

    def test_raise_when_spin_workspace_missing
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => "1",
        Constants::EnvironmentVariables::SPIN_WORKSPACE.to_s => nil,
        Constants::EnvironmentVariables::SPIN_NAMESPACE.to_s => "my-namespace",
      }

      assert_raises(RuntimeError) { Environment.spin_url(env_variables: env_variables) }
    end

    def test_raise_when_spin_namespace_missing
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => "1",
        Constants::EnvironmentVariables::SPIN_WORKSPACE.to_s => "my-workspace",
        Constants::EnvironmentVariables::SPIN_NAMESPACE.to_s => nil,
      }

      assert_raises(RuntimeError) { Environment.spin_url(env_variables: env_variables) }
    end

    def test_infer_when_spin_namespace_missing
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => "1",
        Constants::EnvironmentVariables::INFER_SPIN.to_s => "1",
        Constants::EnvironmentVariables::SPIN_WORKSPACE.to_s => "my-workspace",
        Constants::EnvironmentVariables::SPIN_NAMESPACE.to_s => nil,
      }

      Environment.expects(:infer_spin_namespace)

      Environment.spin_url(env_variables: env_variables)
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
