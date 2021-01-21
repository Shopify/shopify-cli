# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_script_repository"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"

describe Script::Layers::Application::BuildScript do
  include TestHelpers::FakeFS
  describe '.call' do
    let(:language) { 'AssemblyScript' }
    let(:extension_point_type) { 'discount' }
    let(:script_name) { 'name' }
    let(:op_failed_msg) { 'msg' }
    let(:content) { 'content' }
    let(:compiled_type) { 'wasm' }
    let(:extension_point_repository) { Script::Layers::Infrastructure::FakeExtensionPointRepository.new }
    let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }
    let(:task_runner) { stub(compiled_type: compiled_type) }
    let(:script_repository) { Script::Layers::Infrastructure::FakeScriptRepository.new(ctx: @context) }
    let(:script) do
      Script::Layers::Infrastructure::FakeScriptRepository.new(ctx: @context).create_script(language, ep, script_name)
    end

    subject { Script::Layers::Application::BuildScript.call(ctx: @context, task_runner: task_runner, script: script) }

    before do
      Script::Layers::Infrastructure::ScriptRepository.stubs(:new).with(ctx: @context).returns(script_repository)
      Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
      extension_point_repository.create_extension_point(extension_point_type)
    end

    describe 'when build succeeds' do
      it 'should return normally' do
        CLI::UI::Frame.expects(:with_frame_color_override).never
        task_runner.expects(:build).returns(content)
        Script::Layers::Infrastructure::PushPackageRepository
          .any_instance
          .expects(:create_push_package)
          .with(script, content, 'wasm')
        capture_io { subject }
      end
    end

    describe 'when build raises' do
      it 'should output message and raise BuildError' do
        err_msg = 'some error message'
        CLI::UI::Frame.expects(:with_frame_color_override).yields.once
        task_runner.expects(:build).returns(content)
        Script::Layers::Infrastructure::PushPackageRepository
          .any_instance
          .expects(:create_push_package)
          .raises(err_msg)

        io = capture_io do
          assert_raises(Script::Layers::Infrastructure::Errors::BuildError) { subject }
        end

        output = io.join
        assert_match(err_msg, output)
      end

      [
        Script::Layers::Infrastructure::Errors::InvalidBuildScriptError,
        Script::Layers::Infrastructure::Errors::BuildScriptNotFoundError,
        Script::Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError,
      ].each do |e|
        it "it should re-raise #{e} when the raised error is #{e}" do
          CLI::UI::Frame.expects(:with_frame_color_override).yields.once
          task_runner.expects(:build).raises(e)
          capture_io do
            assert_raises(e) { subject }
          end
        end
      end
    end
  end
end
