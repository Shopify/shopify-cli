# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::BuildScript do
  include TestHelpers::FakeFS
  describe ".call" do
    let(:extension_point_type) { "discount" }
    let(:op_failed_msg) { "msg" }
    let(:content) { "content" }
    let(:metadata_file_location) { "metadata.json" }
    let(:metadata_repository) { TestHelpers::FakeMetadataRepository.new }
    let(:metadata) { metadata_repository.get_metadata(metadata_file_location) }
    let(:task_runner) { stub(metadata_file_location: metadata_file_location) }

    let(:extension_point_repository) { TestHelpers::FakeExtensionPointRepository.new }
    let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }

    before do
      extension_point_repository.create_extension_point(extension_point_type)
      Script::Layers::Application::ExtensionPoints
        .stubs(:get)
        .with(type: extension_point_type)
        .returns(ep)

      metadata_repository.create_metadata(metadata_file_location)
      Script::Layers::Infrastructure::MetadataRepository.stubs(:new).returns(metadata_repository)
    end

    subject do
      Script::Layers::Application::BuildScript.call(
        ctx: @context,
        task_runner: task_runner,
      )
    end

    describe "when build succeeds" do
      it "should return normally" do
        CLI::UI::Frame.expects(:with_frame_color_override).never
        task_runner.expects(:build).returns(content)
        capture_io { subject }
      end
    end

    describe "when build raises" do
      describe "when build error" do
        it "should output message and raise BuildError" do
          err_msg = "some error message"
          build_error = Script::Layers::Infrastructure::Errors::BuildError.new(err_msg)

          CLI::UI::Frame.expects(:with_frame_color_override).yields.once
          task_runner.expects(:build).raises(build_error)

          io = capture_io do
            assert_raises(Script::Layers::Infrastructure::Errors::BuildError) { subject }
          end

          output = io.join
          assert_match(err_msg, output)
        end
      end

      describe "when non-build error" do
        it "it should re-raise error when the raised error is not BuildError" do
          task_runner.expects(:build).raises(StandardError)
          capture_io do
            assert_raises(StandardError) { subject }
          end
        end
      end
    end
  end
end
