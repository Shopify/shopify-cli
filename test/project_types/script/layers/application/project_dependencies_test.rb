# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"

describe Script::Layers::Application::ProjectDependencies do
  include TestHelpers::FakeFS

  let(:language) { 'ts' }
  let(:script_name) { 'name' }
  let(:extension_point_type) { 'discount' }
  let(:extension_point_repository) { Script::Layers::Infrastructure::FakeExtensionPointRepository.new }
  let(:extension_point) { extension_point_repository.get_extension_point(extension_point_type) }
  let(:dependency_manager) do
    Script::Layers::Infrastructure::AssemblyScriptDependencyManager
      .new(@context, language, extension_point, script_name)
  end

  before do
    extension_point_repository.create_extension_point(extension_point_type)
    Script::Layers::Infrastructure::DependencyManager.stubs(:for).returns(dependency_manager)
  end

  describe '.bootstrap' do
    it 'should call the DependencyManager.bootstrap method' do
      dependency_manager.expects(:bootstrap).once
      Script::Layers::Application::ProjectDependencies
        .bootstrap(ctx: @context, language: language, extension_point: extension_point, script_name: script_name)
    end
  end

  describe '.install' do
    subject do
      capture_io do
        Script::Layers::Application::ProjectDependencies
          .install(ctx: @context, language: language, extension_point: extension_point, script_name: script_name)
      end
    end

    describe "when dependencies are already installed" do
      before do
        dependency_manager.stubs(:installed?).returns(true)
      end

      it "should skip installation" do
        dependency_manager.expects(:install).never
        subject
      end
    end

    describe "when dependencies are not already installed" do
      before do
        dependency_manager.stubs(:installed?).returns(false)
      end

      describe "when dependency installer succeeds" do
        it "should install dependencies" do
          dependency_manager.expects(:install)
          Script::UI::ErrorHandler.expects(:display_and_raise).never
          subject
        end
      end

      describe "when dependency installer fails" do
        let(:error_message) { 'some message' }
        before do
          dependency_manager.stubs(:install)
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
