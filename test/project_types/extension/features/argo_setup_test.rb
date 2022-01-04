# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"
require "pathname"

module Extension
  module Features
    class ArgoSetupTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)

        @git_template = "https://www.github.com/fake_template.git"
        @initializer = ArgoSetup.new(git_template: @git_template)
        @identifier = "FAKE_ARGO_TYPE"
        @directory = "fake_directory"

        @passing_step = ArgoSetupStep.default { true }
        @failing_step = ArgoSetupStep.default { false }
        @never_run_step = mock.expects(:call).never
      end

      def test_call_sets_up_the_default_setup_steps_runs_them_and_cleans_up
        ArgoSetupSteps.expects(:check_dependencies).with([]).returns(@passing_step).once
        ArgoSetupSteps.expects(:clone_template).with(@git_template).returns(@passing_step).once
        ArgoSetupSteps.expects(:install_dependencies).returns(@passing_step).once
        ArgoSetupSteps.expects(:initialize_project).returns(@passing_step).once

        @initializer.expects(:cleanup).with(@context, true, @directory).once
        @initializer.call(@directory, @identifier, @context)
      end

      def test_if_any_step_fails_subsequent_steps_are_not_run_and_cleanup_is_called
        ArgoSetupSteps.expects(:check_dependencies).with([]).returns(@passing_step).once
        ArgoSetupSteps.expects(:clone_template).with(@git_template).returns(@passing_step).once
        ArgoSetupSteps.expects(:install_dependencies).returns(@failing_step).once
        ArgoSetupSteps.expects(:initialize_project).returns(@never_run_step).once

        @initializer.expects(:cleanup).with(@context, false, @directory).once
        @initializer.call(@directory, @identifier, @context)
      end

      def test_cleanup_runs_cleanup_template_if_success_is_true
        @initializer.expects(:cleanup_template).with(@context).once
        @initializer.expects(:cleanup_on_failure).never

        @initializer.cleanup(@context, true, @directory)
      end

      def test_cleanup_runs_cleanup_on_failure_if_success_is_false
        @initializer.expects(:cleanup_template).never
        @initializer.expects(:cleanup_on_failure).with(@context, @directory).once

        @initializer.cleanup(@context, false, @directory)
      end

      def test_cleanup_template_removes_git_and_script_directories
        @context.expects(:rm_r).with(ArgoSetup::GIT_DIRECTORY).once
        @context.expects(:rm_r).with(ArgoSetup::SCRIPTS_DIRECTORY).once

        @initializer.cleanup_template(@context)
      end

      def test_cleanup_on_failure_removes_extension_directory_if_it_has_been_created
        Dir.expects(:exist?).with(@directory).returns(true).once
        FileUtils.expects(:rm_r).with(@directory).once

        @initializer.cleanup_on_failure(@context, @directory)
      end

      def test_cleanup_on_failure_does_nothing_if_failure_occurred_before_extension_directory_was_created
        Dir.expects(:exist?).with(@directory).returns(false).once
        FileUtils.expects(:rm_r).with(@directory).never

        @initializer.cleanup_on_failure(@context, @directory)
      end
    end
  end
end
