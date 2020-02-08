# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::DeployPackageRepository do
  include TestHelpers::FakeFS

  let(:language) { "ts" }
  let(:extension_point_type) { "vanity_pricing" }
  let(:schema) { "schema" }
  let(:script_name) { "foo" }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point_type, language) }
  let(:script_content) { "BYTECODE" }
  let(:compiled_type) { "wasm" }
  let(:script_path) { script_name }
  let(:build_base) { "#{script_name}/src/build" }
  let(:temp_base) { "#{script_name}/temp" }
  let(:build_file) { "#{build_base}/#{script_name}.wasm" }
  let(:schema_path) { "#{temp_base}/schema" }
  let(:deploy_package_repository) { ShopifyCli::ScriptModule::Infrastructure::DeployPackageRepository.new }
  let(:context) { TestHelpers::FakeContext.new }
  let(:project) { TestHelpers::FakeProject.new }

  before do
    ShopifyCli::ScriptModule::ScriptProject.stubs(:current).returns(project)
    project.directory = script_name
  end

  describe ".create_deploy_package" do
    subject do
      deploy_package_repository.create_deploy_package(script, script_content, schema, compiled_type)
    end

    it "should create a deploy package" do
      deploy_package = subject
      assert_equal script_content, File.read(build_file)
      assert_equal script_content, deploy_package.script_content
    end
  end

  describe ".get_deploy_package" do
    subject { deploy_package_repository.get_deploy_package(script, compiled_type) }

    describe "when script exists" do
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
  end
end
