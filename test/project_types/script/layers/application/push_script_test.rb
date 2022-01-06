# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::PushScript do
  include TestHelpers::FakeFS

  let(:compiled_type) { "wasm" }
  let(:api_key) { "api_key" }
  let(:force) { true }
  let(:use_msgpack) { true }
  let(:extension_point_type) { "discount" }
  let(:metadata) { Script::Layers::Domain::Metadata.new("1", "0", use_msgpack) }
  let(:library_version) { "1.0.0" }
  let(:library_language) { "assemblyscript" }
  let(:library_name) { "@shopify/fake-library-name" }
  let(:library) do
    {
      language: library_language,
      version: library_version,
    }
  end
  let(:schema_minor_version) { "0" }
  let(:script_name) { "name" }
  let(:script_project) do
    script_project_repository.create(
      language: library_language,
      extension_point_type: extension_point_type,
      script_name: script_name,
      env: ShopifyCLI::Resources::EnvFile.new(api_key: api_key, secret: "shh")
    )
  end
  let(:push_package_repository) { TestHelpers::FakePushPackageRepository.new }
  let(:extension_point_repository) { TestHelpers::FakeExtensionPointRepository.new }
  let(:script_project_repository) { TestHelpers::FakeScriptProjectRepository.new }
  let(:task_runner) { stub(compiled_type: "wasm", metadata: metadata, library_version: library_version) }
  let(:ep) { extension_point_repository.get_extension_point(extension_point_type) }
  let(:uuid) { "uuid" }
  let(:url) { "https://some-bucket" }

  before do
    Script::Layers::Infrastructure::PushPackageRepository.stubs(:new).returns(push_package_repository)
    Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
    Script::Layers::Infrastructure::ScriptProjectRepository.stubs(:new).returns(script_project_repository)
    Script::Layers::Infrastructure::Languages::TaskRunner
      .stubs(:for)
      .with(@context, library_language, script_name)
      .returns(task_runner)

    extension_point_repository.create_extension_point(extension_point_type)
    push_package_repository.create_push_package(
      script_project: script_project,
      script_content: "content",
      compiled_type: compiled_type,
      metadata: metadata,
      library: library
    )
  end

  describe ".call" do
    subject { Script::Layers::Application::PushScript.call(ctx: @context, force: force, project: script_project) }

    it "should prepare and push script" do
      script_service_instance = mock
      script_service_instance.expects(:set_app_script).returns(uuid)
      Script::Layers::Infrastructure::ScriptService
        .expects(:new).returns(script_service_instance)

      script_uploader_instance = mock
      script_uploader_instance.expects(:upload).returns(url)
      Script::Layers::Infrastructure::ScriptUploader
        .expects(:new).returns(script_uploader_instance)

      Script::Layers::Application::ProjectDependencies
        .expects(:install).with(ctx: @context, task_runner: task_runner)
      Script::Layers::Application::BuildScript.expects(:call).with(
        ctx: @context,
        task_runner: task_runner,
        script_project: script_project,
        library: library
      )
      capture_io { subject }

      assert_equal uuid, script_project_repository.get.uuid
    end

    describe "when fails to find a library for the API in an unsupported language" do
      before do
        ep.libraries
          .stubs(:for)
          .with(library[:language])
          .returns(nil)
      end

      it "should raise LanguageLibraryForAPINotFoundError" do
        assert_raises(Script::Layers::Infrastructure::Errors::LanguageLibraryForAPINotFoundError) do
          subject
        end
      end
    end

    describe "when the task runner fails to find the library name in the installed dependencies" do
      before do
        task_runner
          .stubs(:library_version)
          .raises(Script::Layers::Infrastructure::Errors::APILibraryNotFoundError.new(library_name))
      end

      it "should raise APILibraryNotFoundError" do
        error = assert_raises(Script::Layers::Infrastructure::Errors::APILibraryNotFoundError) { subject }
        assert_equal library_name, error.library_name
      end
    end
  end
end
