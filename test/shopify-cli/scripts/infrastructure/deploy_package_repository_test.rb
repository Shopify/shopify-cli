# frozen_string_literal: true

require "test_helper"
require_relative "fake_script_repository"

describe ShopifyCli::ScriptModule::Infrastructure::DeployPackageRepository do
  include TestHelpers::FakeFS

  let(:language) { "ts" }
  let(:extension_point_type) { "vanity_pricing" }
  let(:extension_point) do
    ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(extension_point_type, "schema", "types", "example")
  end

  let(:schema) { "schema" }
  let(:script_name) { "foo" }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, language, schema) }
  let(:script_content) { "BYTECODE" }
  let(:script_path) do
    format(ShopifyCli::ScriptModule::Infrastructure::Repository::FOLDER_PATH_TEMPLATE, script_name: script_name)
  end
  let(:build_base) { "#{script_path}/src/build" }
  let(:temp_base) { "#{script_path}/temp" }
  let(:build_file) { "#{build_base}/#{script_name}.wasm" }
  let(:schema_path) { "#{temp_base}/schema" }
  let(:script_repository) { ShopifyCli::ScriptModule::Infrastructure::FakeScriptRepository.new }
  let(:deploy_package_repository) { ShopifyCli::ScriptModule::Infrastructure::DeployPackageRepository.new }
  let(:context) { TestHelpers::FakeContext.new }

  before do
    ShopifyCli::ScriptModule::Infrastructure::ScriptRepository
      .stubs(:new)
      .returns(script_repository)
    ShopifyCli::ScriptModule::Infrastructure::ScriptRepository
      .stubs(:for)
      .returns(ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder.new(script))
  end

  describe ".create_deploy_package" do
    subject { deploy_package_repository.create_deploy_package(script, script_content, schema) }

    it "should create a deploy package" do
      deploy_package = subject
      assert_equal script_content, File.read(build_file)
      assert_equal script_content, deploy_package.script_content
    end
  end

  describe ".get_deploy_package" do
    subject { deploy_package_repository.get_deploy_package(context, language, extension_point_type, script_name) }

    describe "when script exists" do
      before do
        script_repository.create_script(language, extension_point, script_name)
      end

      it "should return the deploy package when valid script and wasm exist" do
        FileUtils.mkdir_p(build_base)
        File.write(build_file, script_content)
        assert_equal build_file, subject.id
        assert_empty subject.schema
      end

      it "should return the deploy package with a valid schema when valid script, wasm and schema exist" do
        FileUtils.mkdir_p(build_base)
        FileUtils.mkdir_p(temp_base)
        File.write(build_file, script_content)
        File.write(schema_path, schema)
        assert_equal subject.schema, schema
      end

      it "should raise DeployPackageNotFoundError when wasm does not exist" do
        FileUtils.mkdir_p(build_base)
        assert_raises(ShopifyCli::ScriptModule::Domain::DeployPackageNotFoundError) { subject }
      end
    end

    describe "when script does not exist" do
      it "should raise ScriptNotFoundError" do
        FileUtils.mkdir_p(build_base)
        File.write(build_file, script_content)
        assert_raises(ShopifyCli::ScriptModule::Domain::ScriptNotFoundError) { subject }
      end
    end
  end
end
