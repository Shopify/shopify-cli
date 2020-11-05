# frozen_string_literal: true
require 'project_types/node/test_helper'

module ShopifyCli
  class JsDepsTest < MiniTest::Test
    def setup
      super
      project_context('app_types', 'node')
      @node_fixture_dependencies = 37
    end

    def test_installs_with_npm_and_returns_true
      JsSystem.any_instance.stubs(:yarn?).returns(false)
      mock_install_call(
        command: %w(npm install --no-audit --quiet),
        returns: ['', '', mock(success?: true)]
      )

      io = capture_io do
        assert JsDeps.install(@context)
      end

      output = io.join
      assert_match(@context.message('core.js_deps.installing', 'npm'), output)
      assert_match(@context.message('core.js_deps.installed'), output)
    end

    def test_install_with_npm_outputs_an_error_message_if_install_fails_and_returns_false
      JsSystem.any_instance.stubs(:yarn?).returns(false)
      mock_install_call(
        command: %w(npm install --no-audit --quiet),
        returns: ['', mock(lines: ['error message']), mock(success?: false)]
      )

      io = capture_io do
        refute JsDeps.install(@context)
      end

      output = io.join
      assert_match(@context.message('core.js_deps.installing', 'npm'), output)
      assert_match('error message', output)
      assert_match(@context.message('core.js_deps.error.install_error'), output)
    end

    def test_installs_with_yarn_and_returns_true
      JsSystem.any_instance.stubs(:yarn?).returns(true)
      mock_install_call(
        command: %w(yarn install --silent),
        returns: ['', '', mock(success?: true)]
      )

      io = capture_io do
        assert JsDeps.install(@context)
      end

      output = io.join
      assert_match(@context.message('core.js_deps.installing', 'yarn'), output)
      assert_match(@context.message('core.js_deps.installed'), output)
    end

    def test_install_with_yarn_outputs_errors_and_an_error_message_if_install_fails_and_returns_false
      JsSystem.any_instance.stubs(:yarn?).returns(true)
      mock_install_call(
        command: %w(yarn install --silent),
        returns: ['', mock(lines: ['error message']), mock(success?: false)]
      )

      io = capture_io do
        refute JsDeps.install(@context)
      end

      output = io.join
      assert_match(@context.message('core.js_deps.installing', 'yarn'), output)
      assert_match('error message', output)
      assert_match(@context.message('core.js_deps.error.install_error'), output)
    end

    private

    def mock_install_call(command:, returns:)
      CLI::Kit::System
        .expects(:capture3)
        .with(*command, env: @context.env, chdir: @context.root)
        .returns(returns)
    end
  end
end
