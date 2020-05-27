# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_script_repository"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"

describe Script::Layers::Application::CreateScript do
  include TestHelpers::FakeFS

  let(:language) { 'ts' }
  let(:extension_point_type) { 'discount' }
  let(:script_name) { 'name' }
  let(:extension_point_repository) { Script::Layers::Infrastructure::FakeExtensionPointRepository.new }
  let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }
  let(:script) { Script::Layers::Infrastructure::FakeScriptRepository.new.create_script(language, ep, script_name) }

  before do
    Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
    extension_point_repository.create_extension_point(extension_point_type)
  end

  describe '.call' do
    subject do
      Script::Layers::Application::CreateScript
        .call(ctx: @context, language: language, script_name: script_name, extension_point_type: extension_point_type)
    end

    it 'should create a new script' do
      Script::Layers::Application::ExtensionPoints.expects(:get).with(type: extension_point_type).returns(ep)
      Script::Layers::Application::CreateScript.expects(:create_project)
      Script::Layers::Application::CreateScript.expects(:create_definition).returns(script)
      subject
    end

    describe 'create_project' do
      subject do
        Script::Layers::Application::CreateScript.send(:create_project, @context, language, script_name, ep)
      end

      it 'should succeed and update ctx root' do
        initial_ctx_root = @context.root
        Script::ScriptProject.expects(:create).with(script_name).once
        Script::ScriptProject
          .expects(:write)
          .with(
            @context,
            project_type: :script,
            organization_id: nil,
            extension_point_type: ep.type,
            script_name: script_name,
          )
        Script::Layers::Application::ProjectDependencies
          .expects(:bootstrap)
          .with(ctx: @context, language: language, extension_point: ep, script_name: script_name)
        Script::Layers::Application::ProjectDependencies
          .expects(:install)
          .with(ctx: @context, language: language, extension_point: ep, script_name: script_name)
        capture_io { subject }
        assert_equal File.join(initial_ctx_root, script_name), @context.root
      end
    end

    describe 'create_definition' do
      subject do
        Script::Layers::Application::CreateScript.send(:create_definition, @context, language, ep, script_name)
      end

      it 'should return new script' do
        Script::Layers::Infrastructure::ScriptRepository
          .any_instance
          .expects(:create_script)
          .with(language, ep, script_name)
          .returns(script)
        Script::Layers::Infrastructure::TestSuiteRepository
          .any_instance
          .expects(:create_test_suite)
          .with(script)
        capture_io { subject }
      end
    end
  end
end
