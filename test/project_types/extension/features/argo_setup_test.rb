# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'
require 'pathname'

module Extension
  module Features
    class ArgoSetupTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)

        @git_template = 'https://www.github.com/fake_template.git'
        @initializer = ArgoSetup.new(git_template: @git_template)
        @identifier = 'FAKE_ARGO_TYPE'
        @directory = 'fake_directory'
      end

      def test_call_clones_repo_then_initializes_project_then_cleans_up
        @initializer.expects(:check_dependencies).with(@context).once
        @initializer.expects(:clone_template).with(@directory, @context).once
        @initializer.expects(:initialize_project).with(@identifier, @context).once
        @initializer.expects(:cleanup).with(@context, @directory).once

        @initializer.call(@directory, @identifier, @context)
      end

      def test_check_dependencies_loops_through_the_provided_dependencies
        execution_mock = Minitest::Mock.new
        execution_mock.expect(:executed, nil)

        test_proc = Proc.new do |context|
          execution_mock.executed
          assert_equal @context, context
        end

        ArgoSetup.new(git_template: @git_template, dependency_checks: [test_proc]).check_dependencies(@context)
        execution_mock.verify
      end

      def test_clone_template_clones_argo_template_git_repo_into_directory_and_updates_context_root
        ShopifyCli::Git.expects(:clone).with(@git_template, @directory, ctx: @context).once

        @initializer.clone_template(@directory, @context)

        assert_equal @directory, Pathname(@context.root).each_filename.to_a.last
      end

      def test_initialize_project_installs_js_deps_and_initializes_the_project_setting_success_true_if_successful
        type_parameter = [ArgoSetup::INITIALIZE_TYPE_PARAMETER % @identifier]
        expected_npm_command = ArgoSetup::NPM_INITIALIZE_COMMAND + type_parameter
        expected_yarn_command = ArgoSetup::YARN_INITIALIZE_COMMAND + type_parameter

        ShopifyCli::JsDeps.any_instance.expects(:install).once
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: expected_yarn_command, npm: expected_npm_command)
          .returns(true)
          .once

        @initializer.initialize_project(@identifier, @context)
        assert @initializer.success
      end

      def test_initialize_project_sets_success_to_false_if_initialize_command_fails
        type_parameter = [ArgoSetup::INITIALIZE_TYPE_PARAMETER % @identifier]
        expected_npm_command = ArgoSetup::NPM_INITIALIZE_COMMAND + type_parameter
        expected_yarn_command = ArgoSetup::YARN_INITIALIZE_COMMAND + type_parameter

        ShopifyCli::JsDeps.any_instance.expects(:install).once
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: expected_yarn_command, npm: expected_npm_command)
          .returns(false)
          .once

        @initializer.initialize_project(@identifier, @context)
        refute @initializer.success
      end

      def test_cleanup_runs_cleanup_template_if_success_is_true
        @initializer.success = true
        @initializer.expects(:cleanup_template).with(@context).once
        @initializer.expects(:cleanup_on_failure).never

        @initializer.cleanup(@context, @directory)
      end

      def test_cleanup_runs_cleanup_on_failure_if_success_is_false
        @initializer.success = false
        @initializer.expects(:cleanup_template).never
        @initializer.expects(:cleanup_on_failure).with(@context, @directory).once

        @initializer.cleanup(@context, @directory)
      end

      def test_cleanup_template_removes_git_and_script_directories
        @context.expects(:rm_r).with(ArgoSetup::GIT_DIRECTORY).once
        @context.expects(:rm_r).with(ArgoSetup::SCRIPTS_DIRECTORY).once

        @initializer.cleanup_template(@context)
      end

      def test_cleanup_on_failure_removes_extension_directory_if_it_has_been_created
        Dir.expects(:exists?).with(@directory).returns(true).once
        FileUtils.expects(:rm_r).with(@directory).once

        @initializer.cleanup_on_failure(@context, @directory)
      end

      def test_cleanup_on_failure_does_nothing_if_failure_occurred_before_extension_directory_was_created
        Dir.expects(:exists?).with(@directory).returns(false).once
        FileUtils.expects(:rm_r).with(@directory).never

        @initializer.cleanup_on_failure(@context, @directory)
      end
    end
  end
end
