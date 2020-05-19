# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_script_repository"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"

describe Script::Layers::Application::BuildScript do
  include TestHelpers::FakeFS
  describe '.call' do
    let(:language) { 'ts' }
    let(:extension_point_type) { 'discount' }
    let(:script_name) { 'name' }
    let(:op_failed_msg) { 'msg' }
    let(:content) { 'content' }
    let(:schema) { 'schema' }
    let(:extension_point_repository) { Script::Layers::Infrastructure::FakeExtensionPointRepository.new }
    let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }
    let(:script_repository) { Script::Layers::Infrastructure::FakeScriptRepository.new }
    let(:script) do
      Script::Layers::Infrastructure::FakeScriptRepository.new.create_script(language, ep, script_name)
    end

    subject { Script::Layers::Application::BuildScript.call(ctx: @context, script: script) }

    before do
      Script::Layers::Infrastructure::ScriptRepository.stubs(:new).returns(script_repository)
      Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
      extension_point_repository.create_extension_point(extension_point_type)
    end

    describe 'when build succeeds' do
      it 'should return normally' do
        CLI::UI::Frame.expects(:with_frame_color_override).never
        Script::Layers::Infrastructure::AssemblyScriptWasmBuilder
          .any_instance
          .expects(:build)
          .returns([content, schema])
        Script::Layers::Infrastructure::DeployPackageRepository
          .any_instance
          .expects(:create_deploy_package)
          .with(script, content, schema, 'wasm')
        capture_io { subject }
      end
    end

    describe 'when build raises' do
      it 'should output message and raise BuildError' do
        err_msg = 'some error message'
        CLI::UI::Frame.expects(:with_frame_color_override).yields.once
        Script::Layers::Infrastructure::AssemblyScriptWasmBuilder
          .any_instance
          .expects(:build)
          .returns([content, schema])
        Script::Layers::Infrastructure::DeployPackageRepository
          .any_instance
          .expects(:create_deploy_package)
          .raises(err_msg)

        io = capture_io do
          assert_raises(Script::Layers::Infrastructure::Errors::BuildError) { subject }
        end

        output = io.join
        assert_match(err_msg, output)
      end
    end
  end
end
