# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"
require "project_types/script/layers/infrastructure/fake_config_ui_repository"

describe Script::Layers::Application::CreateScript do
  include TestHelpers::FakeFS

  let(:language) { "AssemblyScript" }
  let(:extension_point_type) { "discount" }
  let(:script_name) { "name" }
  let(:compiled_type) { "wasm" }
  let(:no_config_ui) { false }
  let(:extension_point_repository) { Script::Layers::Infrastructure::FakeExtensionPointRepository.new }
  let(:config_ui_repository) { Script::Layers::Infrastructure::FakeConfigUiRepository.new }
  let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }
  let(:task_runner) { stub(compiled_type: compiled_type) }
  let(:project_creator) { stub }
  let(:project_directory) { "/path" }
  let(:script_project) do
    TestHelpers::FakeScriptProject.new(language: language, directory: project_directory, script_name: script_name)
  end

  before do
    Script::ScriptProject.stubs(:current).returns(script_project)
    Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
    Script::Layers::Infrastructure::ConfigUiRepository.stubs(:new).returns(config_ui_repository)

    extension_point_repository.create_extension_point(extension_point_type)
    Script::Layers::Infrastructure::TaskRunner
      .stubs(:for)
      .with(@context, language, script_name)
      .returns(task_runner)
    Script::Layers::Infrastructure::ProjectCreator
      .stubs(:for)
      .with(@context, language, ep, script_name, project_directory)
      .returns(project_creator)
  end

  describe ".call" do
    subject do
      Script::Layers::Application::CreateScript.call(
        ctx: @context,
        language: language,
        script_name: script_name,
        extension_point_type: extension_point_type,
        no_config_ui: no_config_ui
      )
    end

    it "should create a new script" do
      Script::Layers::Application::ExtensionPoints
        .expects(:get)
        .with(type: extension_point_type)
        .returns(ep)
      Script::Layers::Application::CreateScript
        .expects(:setup_project)
        .with(
          ctx: @context,
          language: language,
          script_name: script_name,
          extension_point: ep,
          no_config_ui: no_config_ui
        ).returns(script_project)
      Script::Layers::Application::CreateScript
        .expects(:install_dependencies)
        .with(@context, language, script_name, project_creator)
      Script::Layers::Application::CreateScript
        .expects(:bootstrap)
        .with(@context, project_creator)
      subject
    end

    describe ".setup_project" do
      subject do
        Script::Layers::Application::CreateScript.send(
          :setup_project,
          ctx: @context,
          language: language,
          script_name: script_name,
          extension_point: ep,
          no_config_ui: no_config_ui
        )
      end

      describe "when no_config_ui is false" do
        let(:no_config_ui) { false }
        let(:expected_config_ui_filename) { "config-ui.yml" }
        let(:expected_config_ui_content) do
          "---\nversion: 1\ntype: single\ntitle: #{script_name}\ndescription: ''\nfields: []\n"
        end

        it "should create a config_ui_file and store the filename in the project config" do
          Script::ScriptProject.expects(:create).with(@context, script_name).once
          Script::ScriptProject
            .expects(:write)
            .with(
              @context,
              project_type: :script,
              organization_id: nil,
              extension_point_type: ep.type,
              script_name: script_name,
              language: language,
              config_ui_file: expected_config_ui_filename
            )
          capture_io { subject }

          config_ui = config_ui_repository.get_config_ui(expected_config_ui_filename)

          refute_nil config_ui
          assert_equal expected_config_ui_filename, config_ui.filename
          assert_equal expected_config_ui_content, config_ui.content
        end
      end

      describe "when no_config_ui is true" do
        let(:no_config_ui) { true }

        it "should write the config without config_ui_file field" do
          Script::ScriptProject.expects(:create).with(@context, script_name).once
          Script::ScriptProject
            .expects(:write)
            .with(
              @context,
              project_type: :script,
              organization_id: nil,
              extension_point_type: ep.type,
              script_name: script_name,
              language: language,
            )
          capture_io do
            assert_equal script_project, subject
          end
        end
      end
    end

    describe "install_dependencies" do
      subject do
        Script::Layers::Application::CreateScript
          .send(:install_dependencies, @context, language, script_name, project_creator)
      end

      it "should return new script" do
        Script::Layers::Application::ProjectDependencies
          .expects(:install)
          .with(ctx: @context, task_runner: task_runner)
        project_creator.expects(:setup_dependencies)
        capture_io { subject }
      end
    end

    describe "bootstrap" do
      subject do
        Script::Layers::Application::CreateScript
          .send(:bootstrap, @context, project_creator)
      end

      it "should return new script" do
        spinner = TestHelpers::FakeUI::FakeSpinner.new
        spinner.expects(:update_title).with(@context.message("script.create.created"))
        Script::UI::StrictSpinner.expects(:spin).with(@context.message("script.create.creating")).yields(spinner)
        project_creator.expects(:bootstrap)
        capture_io { subject }
      end
    end
  end
end
