# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::BuildScript do
  include TestHelpers::FakeFS
  describe ".call" do
    let(:library_name) { "@shopify/fake-library-name" }
    let(:extension_point_type) { "discount" }
    let(:op_failed_msg) { "msg" }
    let(:content) { "content" }
    let(:metadata_file_location) { "metadata.json" }
    let(:metadata_repository) { TestHelpers::FakeMetadataRepository.new }
    let(:metadata) { metadata_repository.get_metadata(metadata_file_location) }
    let(:task_runner) { stub(metadata_file_location: metadata_file_location) }
    let(:script_project) { stub }

    let(:library_language) { "assemblyscript" }
    let(:library_version) { "1.0.0" }

    let(:library) do
      {
        language: library_language,
        version: library_version,
      }
    end

    let(:extension_point_repository) { TestHelpers::FakeExtensionPointRepository.new }
    let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }

    before do
      task_runner
        .stubs(:library_version)
        .returns("1.0.0")

      extension_point_repository.create_extension_point(extension_point_type)
      Script::Layers::Application::ExtensionPoints
        .stubs(:get)
        .with(type: extension_point_type)
        .returns(ep)

      script_project
        .stubs(:extension_point_type)
        .returns(extension_point_type)
      script_project
        .stubs(:language)
        .returns(library_language)

      metadata_repository.create_metadata(metadata_file_location)
      Script::Layers::Infrastructure::MetadataRepository.stubs(:new).returns(metadata_repository)
    end

    subject do
      Script::Layers::Application::BuildScript.call(
        ctx: @context,
        task_runner: task_runner,
        script_project: script_project,
        library: library,
      )
    end

    describe "when build succeeds" do
      it "should return normally" do
        CLI::UI::Frame.expects(:with_frame_color_override).never
        task_runner.expects(:build).returns(content)
        Script::Layers::Infrastructure::PushPackageRepository.any_instance.expects(:create_push_package).with(
          script_project: script_project,
          script_content: content,
          metadata: metadata,
          library: library
        )
        capture_io { subject }
      end
    end

    describe "when build raises" do
      it "should output message and raise BuildError" do
        err_msg = "some error message"
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
