# frozen_string_literal: true
require "test_helper"

module ShopifyCLI
  class EnvironmentTest < MiniTest::Test
    def setup 
      super
      @mock_spin_instance = {
        "name": name,
        "fqdn": "#{name}.namespace.host",
      }
    end

    def test_ruby_version_when_the_command_raises
      # Given
      context = TestHelpers::FakeContext.new
      stat = mock("error", success?: false)
      out = ""
      err = "Error executing the command"
      context.expects(:capture3)
        .with('ruby -e "puts RUBY_VERSION"')
        .returns([out, err, stat])

      # When/Then
      error = assert_raises ShopifyCLI::Abort do
        Environment.ruby_version(context: context)
      end
      assert_equal err, error.message
    end

    def test_ruby_version
      # Given
      context = TestHelpers::FakeContext.new
      stat = mock("success", success?: true)
      out = '"3.2.1"'
      err = ""
      context.expects(:capture3)
        .with('ruby -e "puts RUBY_VERSION"')
        .returns([out, err, stat])

      # When
      got = Environment.ruby_version(context: context)

      # Then
      assert_equal ::Semantic::Version.new("3.2.1"), got
    end

    def test_node_version_when_the_command_raises
      # Given
      context = TestHelpers::FakeContext.new
      stat = mock("error", success?: false)
      out = ""
      err = "Error executing the command"
      context.expects(:capture3)
        .with("node", "--version")
        .returns([out, err, stat])

      # When/Then
      error = assert_raises ShopifyCLI::Abort do
        Environment.node_version(context: context)
      end
      assert_equal err, error.message
    end

    def test_node_version
      # Given
      context = TestHelpers::FakeContext.new
      stat = mock("success", success?: true)
      out = "v3.2.1"
      err = ""
      context.expects(:capture3)
        .with("node", "--version")
        .returns([out, err, stat])

      # When
      got = Environment.node_version(context: context)

      # Then
      assert_equal ::Semantic::Version.new("3.2.1"), got
    end

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

    def test_partners_domain_returns_the_right_value_when_production_instance
      # Given/When
      got = Environment.partners_domain

      # Then
      assert_equal "partners.shopify.com", got
    end

    def test_spin_url_returns_complete_override
      # Given
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => "1",
        Constants::EnvironmentVariables::SPIN_WORKSPACE.to_s => "abcd",
        Constants::EnvironmentVariables::SPIN_NAMESPACE.to_s => "namespace",
        Constants::EnvironmentVariables::SPIN_HOST.to_s => "host",
      }

      # When
      got = Environment.partners_domain(env_variables: env_variables)

      # Then
      assert_equal "partners.abcd.namespace.host", got
    end

    def test_spin_url_raises_partial_override
      # Given
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => "1",
        Constants::EnvironmentVariables::SPIN_WORKSPACE.to_s => "abcd",
        Constants::EnvironmentVariables::SPIN_NAMESPACE.to_s => "namespace",
      }

      # When/Then
      assert_raises(RuntimeError) do
        Environment.partners_domain(env_variables: env_variables)
      end
    end

    def test_spin_url_returns_specified_instance_url
      # Given
      env_variables = {
        Constants::EnvironmentVariables::SPIN.to_s => "1",
        Constants::EnvironmentVariables::SPIN_INSTANCE.to_s => "abcd",
      }
      Environment.expects(:spin_show).with.returns(@mock_spin_instance.to_json)

      # When
      got = Environment.partners_domain(env_variables: env_variables)

      # Then
      assert_equal "partners.#{@mock_spin_instance[:fqdn]}", got
    end

    def test_spin_url_returns_latest
      # Given
      env_variables = {
        Constants::EnvironmentVariables::SPIN_PARTNERS.to_s => "1",
      }
      Environment.expects(:spin_show).with(latest: true).returns(@mock_spin_instance.to_json)

      # When
      got = Environment.partners_domain(env_variables: env_variables)

      # Then
      assert_equal "partners.#{@mock_spin_instance[:fqdn]}", got
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
