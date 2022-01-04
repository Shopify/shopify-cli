# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoSetupStepsTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)

        @git_template = "https://www.github.com/fake_template.git"
        @identifier = "FAKE_ARGO_TYPE"
        @directory = "fake_directory"
        @system = ShopifyCLI::JsSystem.new(ctx: @context)
      end

      def test_check_dependencies_loops_through_the_provided_dependencies
        execution_mock = Minitest::Mock.new
        execution_mock.expect(:executed, nil)

        test_proc = proc do |context|
          execution_mock.executed
          assert_equal @context, context
        end

        call_step(ArgoSetupSteps.check_dependencies([test_proc]))
        execution_mock.verify
      end

      def test_clone_template_clones_argo_template_git_repo_into_directory_and_updates_context_root
        ShopifyCLI::Git.expects(:clone).with(@git_template, @directory, ctx: @context).once

        call_step(ArgoSetupSteps.clone_template(@git_template))

        assert_equal @directory, Pathname(@context.root).each_filename.to_a.last
      end

      def test_install_dependencies_calls_js_deps_to_install_dependencies_and_returns_the_install_result
        ShopifyCLI::JsDeps.any_instance.expects(:install).returns(true).once
        assert call_step(ArgoSetupSteps.install_dependencies)

        ShopifyCLI::JsDeps.any_instance.expects(:install).returns(false).once
        refute call_step(ArgoSetupSteps.install_dependencies)
      end

      def test_initialize_project_runs_the_initialize_command_with_js_system_and_returns_true_if_successful
        type_parameter = [ArgoSetupSteps::INITIALIZE_TYPE_PARAMETER % @identifier]
        expected_npm_command = ArgoSetupSteps::NPM_INITIALIZE_COMMAND + type_parameter
        expected_yarn_command = ArgoSetupSteps::YARN_INITIALIZE_COMMAND + type_parameter

        @system
          .expects(:call)
          .with(yarn: expected_yarn_command, npm: expected_npm_command)
          .returns(true)
          .once

        assert call_step(ArgoSetupSteps.initialize_project)
      end

      def test_initialize_project_runs_the_initialize_command_with_js_system_and_returns_false_when_fails
        type_parameter = [ArgoSetupSteps::INITIALIZE_TYPE_PARAMETER % @identifier]
        expected_npm_command = ArgoSetupSteps::NPM_INITIALIZE_COMMAND + type_parameter
        expected_yarn_command = ArgoSetupSteps::YARN_INITIALIZE_COMMAND + type_parameter

        @system
          .expects(:call)
          .with(yarn: expected_yarn_command, npm: expected_npm_command)
          .returns(false)
          .once

        refute call_step(ArgoSetupSteps.initialize_project)
      end

      private

      def call_step(step, context: @context, identifier: @identifier, directory_name: @directory, system: @system)
        step.call(context, identifier, directory_name, system)
      end
    end
  end
end
