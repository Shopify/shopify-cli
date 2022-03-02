# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/test_helpers"

describe Script::Layers::Application::ProjectDependencies do
  include TestHelpers::FakeFS

  let(:extension_point_type) { "discount" }
  let(:extension_point_repository) { TestHelpers::FakeExtensionPointRepository.new }
  let(:extension_point) { extension_point_repository.get_extension_point(extension_point_type) }
  let(:task_runner) { stub }

  before do
    extension_point_repository.create_extension_point(extension_point_type)
    Script::Layers::Infrastructure::Languages::TaskRunner.stubs(:for).returns(task_runner)
  end

  describe ".install" do
    subject do
      capture_io do
        Script::Layers::Application::ProjectDependencies
          .install(ctx: @context, task_runner: task_runner)
      end
    end

    describe "when dependencies are already installed" do
      before do
        task_runner.stubs(:dependencies_installed?).returns(true)
      end

      it "should skip installation" do
        task_runner.expects(:install_dependencies).never
        subject
      end
    end

    describe "when dependencies are not already installed" do
      before do
        task_runner.stubs(:dependencies_installed?).returns(false)
      end

      describe "when dependency installer succeeds" do
        it "should install dependencies" do
          task_runner.expects(:install_dependencies)
          Script::UI::ErrorHandler.expects(:display_and_raise).never
          subject
        end
      end

      describe "when dependency installer fails" do
        let(:error_message) { "some message" }
        before do
          task_runner.stubs(:install_dependencies)
            .raises(Script::Layers::Infrastructure::Errors::DependencyInstallError, error_message)
        end

        it "should display error message" do
          @context.expects(:puts).with("\n#{error_message}")
          assert_raises(Script::Layers::Infrastructure::Errors::DependencyInstallError) do
            subject
          end
        end
      end
    end
  end
end
