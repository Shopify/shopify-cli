# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::CreateScript do
  include TestHelpers::FakeFS

  let(:title) { "path" }

  let(:extension_point_repository) { TestHelpers::FakeExtensionPointRepository.new }
  let(:script_project_repository) { TestHelpers::FakeScriptProjectRepository.new(context) }
  let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }
  let(:task_runner) { stub }

  let(:language) { "assemblyscript" }
  let(:extension_point_type) { "payment-methods" }
  let(:example_config) { extension_point_repository.example_config(extension_point_type) }
  let(:domain) { example_config["domain"] }
  let(:sparse_checkout_repo) { example_config["libraries"][language]["repo"] }
  let(:sparse_checkout_branch) do
    "master"
  end   # TODO: update once create script can take a command line argument
  let(:sparse_checkout_set_path) { "#{domain}/#{language}/#{extension_point_type}/default" }

  let(:project_creator) { stub }
  let(:context) { TestHelpers::FakeContext.new }

  let(:script_project) do
    script_project_repository.create(
      language: language,
      extension_point_type: extension_point_type,
      title: title
    )
  end

  before do
    Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
    Script::Layers::Infrastructure::ScriptProjectRepository.stubs(:new).returns(script_project_repository)

    extension_point_repository.create_extension_point(extension_point_type)
    Script::Layers::Infrastructure::Languages::TaskRunner
      .stubs(:for)
      .with(context, language)
      .returns(task_runner)
    Script::Layers::Infrastructure::Languages::ProjectCreator
      .stubs(:for)
      .with(
        ctx: context,
        language: language,
        type: extension_point_type,
        project_name: title,
        path_to_project: script_project.id,
        sparse_checkout_repo: sparse_checkout_repo,
        sparse_checkout_branch: sparse_checkout_branch,
        sparse_checkout_set_path: sparse_checkout_set_path,
      )
      .returns(project_creator)

    project_creator.stubs(:sparse_checkout_repo).returns(sparse_checkout_repo)
    project_creator.stubs(:path_to_project).returns(script_project.id)
  end

  describe ".call" do
    subject do
      ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(nil)

      Script::Layers::Application::CreateScript.call(
        ctx: context,
        language: language,
        sparse_checkout_branch: sparse_checkout_branch,
        title: title,
        extension_point_type: extension_point_type,
      )
    end

    describe "failure" do
      describe "when an error occurs after the project folder was created" do
        before { Script::Layers::Application::CreateScript.expects(:install_dependencies).raises(StandardError) }

        it "should raise the error and delete the created folder" do
          script_project_repository
            .expects(:delete_project_directory)
            .with

          assert_raises(StandardError) { subject }
        end
      end

      describe "when a ScriptProjectAlreadyExistsError error occurs" do
        before do
          script_project_repository
            .expects(:create_project_directory)
            .raises(Script::Layers::Infrastructure::Errors::ScriptProjectAlreadyExistsError)
        end

        it "should raise the error" do
          assert_raises(Script::Layers::Infrastructure::Errors::ScriptProjectAlreadyExistsError) { subject }
        end
      end
    end

    describe "success" do
      before do
        Script::Layers::Application::ExtensionPoints
          .expects(:get)
          .with(type: extension_point_type)
          .returns(ep)
        Script::Layers::Application::CreateScript
          .expects(:install_dependencies)
          .with(context, language, title, project_creator)
      end

      it "should create a new script" do
        script_project_repository
          .expects(:create_project_directory)
          .with
        subject
      end

      it "should update the script configuration file" do
        subject

        script_config = script_project_repository.get.script_config
        assert_equal "1", script_config.version
      end
    end

    describe "install_dependencies" do
      subject do
        Script::Layers::Application::CreateScript
          .send(:install_dependencies, context, language, title, project_creator)
      end

      it "should return new script" do
        Script::Layers::Application::ProjectDependencies
          .expects(:install)
          .with(ctx: context, task_runner: task_runner)
        project_creator.expects(:setup_dependencies)
        capture_io { subject }
      end
    end
  end
end
