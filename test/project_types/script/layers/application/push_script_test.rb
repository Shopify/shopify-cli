# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_script_repository"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"
require "project_types/script/layers/infrastructure/fake_push_package_repository"

describe Script::Layers::Application::PushScript do
  include TestHelpers::FakeFS

  let(:compiled_type) { 'wasm' }
  let(:language) { 'AssemblyScript' }
  let(:api_key) { 'api_key' }
  let(:force) { true }
  let(:extension_point_type) { 'discount' }
  let(:script_name) { 'name' }
  let(:project) do
    TestHelpers::FakeScriptProject
      .new(language: @language, extension_point_type: @extension_point_type, script_name: @script_name)
  end
  let(:push_package_repository) { Script::Layers::Infrastructure::FakePushPackageRepository.new }
  let(:extension_point_repository) { Script::Layers::Infrastructure::FakeExtensionPointRepository.new }
  let(:task_runner) { stub(compiled_type: 'wasm') }
  let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }
  let(:script_repository) { Script::Layers::Infrastructure::FakeScriptRepository.new(@context) }
  let(:script) { script_repository.create_script(language, ep, script_name) }

  before do
    Script::Layers::Infrastructure::PushPackageRepository.stubs(:new).returns(push_package_repository)
    Script::Layers::Infrastructure::ScriptRepository.stubs(:new).with(ctx: @context).returns(script_repository)
    Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
    Script::Layers::Infrastructure::TaskRunner
      .stubs(:for)
      .with(@context, language, script_name)
      .returns(task_runner)
    Script::ScriptProject.stubs(:current).returns(project)
    extension_point_repository.create_extension_point(extension_point_type)
    push_package_repository.create_push_package(script, 'content', compiled_type)
  end

  describe '.call' do
    subject do
      Script::Layers::Application::PushScript.call(
        ctx: @context,
        language: language,
        extension_point_type: extension_point_type,
        script_name: script_name,
        api_key: api_key,
        force: force
      )
    end

    it 'should prepare and push script' do
      script_service_instance = Script::Layers::Infrastructure::ScriptService.new(ctx: @context)
      Script::Layers::Application::ProjectDependencies
        .expects(:install).with(ctx: @context, task_runner: task_runner)
      Script::Layers::Application::BuildScript
        .expects(:call).with(ctx: @context, task_runner: task_runner, script: script)
      Script::Layers::Infrastructure::ScriptService
        .expects(:new).returns(script_service_instance)
      Script::Layers::Domain::PushPackage
        .any_instance.expects(:push).with(script_service_instance, api_key, force)
      capture_io { subject }
    end
  end
end
