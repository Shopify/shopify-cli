# frozen_string_literal: true
require 'project_types/node/test_helper'

module ShopifyCli
  class JsDepsTest < MiniTest::Test
    def setup
      project_context('app_types', 'node')
    end

    def test_installs_with_npm_and_returns_true
      JsSystem.any_instance.stubs(:yarn?).returns(false)
      CLI::Kit::System.expects(:system).with(
        'npm', 'install', '--no-audit', '--no-optional', '--silent',
        env: @context.env,
        chdir: @context.root,
      ).returns(mock(success?: true))

      io = capture_io do
        assert JsDeps.install(@context)
      end

      output = io.join
      assert_match('Installing dependencies with npm...', output)
    end

    def test_install_with_npm_outputs_an_error_message_if_install_fails_and_returns_false
      JsSystem.any_instance.stubs(:yarn?).returns(false)
      CLI::Kit::System.expects(:system).with(
        'npm', 'install', '--no-audit', '--no-optional', '--silent',
        env: @context.env,
        chdir: @context.root,
      ).returns(mock(success?: false))

      io = capture_io do
        refute JsDeps.install(@context)
      end

      output = io.join
      assert_match(@context.message('core.js_deps.error.install_error'), output)
    end

    def test_installs_with_yarn_and_returns_true
      JsSystem.any_instance.stubs(:yarn?).returns(true)
      CLI::Kit::System.expects(:system).with(
        'yarn', 'install', '--silent',
        chdir: @context.root
      ).returns(mock(success?: true))

      io = capture_io do
        assert JsDeps.install(@context)
      end

      output = io.join
      assert_match('Installing dependencies with yarn...', output)
    end

    def test_install_with_yarn_outputs_an_error_message_if_install_fails_and_returns_false
      JsSystem.any_instance.stubs(:yarn?).returns(true)
      CLI::Kit::System.expects(:system).with(
        'yarn', 'install', '--silent',
        chdir: @context.root
      ).returns(mock(success?: false))

      io = capture_io do
        refute JsDeps.install(@context)
      end

      output = io.join
      assert_match(@context.message('core.js_deps.error.install_error'), output)
    end
  end
end
