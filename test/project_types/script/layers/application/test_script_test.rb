# frozen_string_literal: true

require 'project_types/script/test_helper'
require "project_types/script/layers/infrastructure/fake_extension_point_repository"

describe Script::Layers::Application::TestScript do
  include TestHelpers::FakeFS

  let(:language) { 'ts' }
  let(:extension_point_type) { 'extension_point_type' }
  let(:script_name) { 'script_name' }
  let(:project) do
    TestHelpers::FakeScriptProject
      .new(language: language, extension_point_type: extension_point_type, script_name: script_name)
  end
  let(:extension_point_repository) { Script::Layers::Infrastructure::FakeExtensionPointRepository.new }
  let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }

  before do
    Script::ScriptProject.stubs(:current).returns(project)
    Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
    extension_point_repository.create_extension_point(extension_point_type)
    FileUtils.mkdir("/test")
  end

  describe '.call' do
    subject do
      Script::Layers::Application::TestScript.call(
        ctx: @context,
        language: language,
        extension_point_type: extension_point_type,
        script_name: script_name
      )
    end

    before do
      Script::Layers::Application::ProjectDependencies
        .expects(:install)
        .with(ctx: @context, language: language, extension_point: ep, script_name: script_name)
      Script::Layers::Application::TestScript
        .expects(:ensure_valid_test_suite)
        .returns(true)
    end

    describe 'when tests are run successfully' do
      it 'should succeed' do
        Script::Layers::Infrastructure::AssemblyScriptTestRunner
          .any_instance.expects(:run_tests)
          .returns(true)
        capture_io { subject }
      end
    end

    describe 'when a test fails' do
      it 'should raise TestError' do
        Script::Layers::Infrastructure::AssemblyScriptTestRunner
          .any_instance.expects(:run_tests)
          .returns(false)
        assert_raises(Script::TestError) do
          capture_io { subject }
        end
      end
    end
  end
end
