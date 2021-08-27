# frozen_string_literal: true
require "test_helper"

module ShopifyCli
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

    def test_use_local_partners_instance_returns_false_when_the_env_variable_is_not_set
      # Given/When
      got = Environment.use_local_partners_instance?(env_variables: {})

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

    def test_partners_domain_returns_the_right_value_when_production_instance
      # Given/When
      got = Environment.partners_domain

      # Then
      assert_equal "partners.shopify.com", got
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
