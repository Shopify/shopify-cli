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

  let(:script_name) { "foo" }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, language, "schema") }
  let(:script_content) { "BYTECODE" }
  let(:build_base) do
    "#{format(ShopifyCli::ScriptModule::Infrastructure::Repository::FOLDER_PATH_TEMPLATE, script_name: script_name)}"\
    "/src/build"
  end
  let(:build_file) { "#{build_base}/#{script_name}.wasm" }
  let(:script_repository) { ShopifyCli::ScriptModule::Infrastructure::FakeScriptRepository.new }
  let(:deploy_package_repository) { ShopifyCli::ScriptModule::Infrastructure::DeployPackageRepository.new }

  before do
    ShopifyCli::ScriptModule::Infrastructure::ScriptRepository
      .stubs(:new)
      .returns(script_repository)
    ShopifyCli::ScriptModule::Infrastructure::ScriptRepository
      .stubs(:for)
      .returns(ShopifyCli::ScriptModule::Infrastructure::TypeScriptWasmBuilder.new(script))
  end

  describe ".create_deploy_package" do
    subject { deploy_package_repository.create_deploy_package(script, script_content, "schema") }

    it "should create a deploy package" do
      deploy_package = subject
      assert_equal script_content, File.read(build_file)
      assert_equal script_content, deploy_package.script_content
    end
  end
end
