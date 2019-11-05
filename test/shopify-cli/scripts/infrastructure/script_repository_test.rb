# frozen_string_literal: true

require "test_helper"
require_relative "fake_configuration_repository"
require_relative "fake_extension_point_repository"

describe ShopifyCli::ScriptModule::Infrastructure::ScriptRepository do
  let(:extension_point_type) { "discount" }
  let(:extension_point_schema) { "schema" }
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(extension_point_type, extension_point_schema, "types", "example") }
  let(:script_name) { "myscript" }
  let(:language) { "ts" }
  let(:script_source_base) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH}/#{extension_point_type}/#{script_name}" }
  let(:script_source_file) { "#{script_source_base}/#{script_name}.#{language}" }
  let(:script_types_directory) { "#{script_source_base}/types" }
  let(:script_schema_file) { "#{script_types_directory}/#{extension_point_type}.schema" }
  let(:expected_script_id) { "#{extension_point_type}/#{script_name}.#{language}" }
  let(:template_base) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH}/templates/" }
  let(:template_file) { "#{template_base}/typescript/#{extension_point_type}.#{language}" }
  let(:runtime_types_path) do
    "#{ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH}/sdk/shopify_runtime_types.ts"
  end
  let(:extension_point_repository) { ShopifyCli::ScriptModule::Infrastructure::FakeExtensionPointRepository.new }
  let(:script_repository) { ShopifyCli::ScriptModule::Infrastructure::ScriptRepository.new }

  before do
    ShopifyCli::ScriptModule::Infrastructure::ExtensionPointRepository
      .stubs(:new)
      .returns(extension_point_repository)
  end

  describe ".create_script" do
    subject { script_repository.create_script(language, extension_point, script_name) }
    it "should create the script correctly from the template" do
      FakeFS.with_fresh do
        FakeFS::FileSystem.clone(template_file)
        FakeFS::FileSystem.clone(runtime_types_path)
        FileUtils.mkdir_p(script_source_base)

        script = subject
        assert File.exist?(script_source_file)

        assert_equal expected_script_id, script.id
        assert_equal script_name, script.name
        assert_equal extension_point, script.extension_point
        assert_equal extension_point_schema, script.schema
      end
    end
  end

  describe ".get_script" do
    subject { script_repository.get_script(language, extension_point.type, script_name) }

    describe "when extension point is valid" do
      before do
        extension_point_repository.create_extension_point(extension_point_type)
      end

      it "should return the requested script" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(script_source_base)
          FileUtils.mkdir_p(script_types_directory)
          File.write(script_source_file, "//script code")
          File.write(script_schema_file, extension_point_schema)
          script = subject
          assert_equal expected_script_id, script.id
          assert_equal script_name, script.name
          assert_equal extension_point_repository.get_extension_point(extension_point_type), script.extension_point
          assert_equal extension_point_schema, script.schema
        end
      end

      it "should raise ScriptNotFoundError when script source file does not exist" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(script_source_base)
          e = assert_raises(ShopifyCli::ScriptModule::Domain::ScriptNotFoundError) { subject }
          assert_equal script_source_file, e.script_name
        end
      end

      it "should raise ScriptNotFoundError when schema file does not exist" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(script_source_base)
          File.write(script_source_file, "//script code")
          e = assert_raises(ShopifyCli::ScriptModule::Domain::ScriptNotFoundError) { subject }
          assert_equal script_source_file, e.script_name
        end
      end
    end

    describe "when extension point does not exist" do
      it "should raise InvalidExtensionPointError" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(script_source_base)
          FileUtils.mkdir_p(script_types_directory)
          File.write(script_source_file, "//script code")
          File.write(script_schema_file, "//schema code")
          assert_raises(ShopifyCli::ScriptModule::Domain::InvalidExtensionPointError) { subject }
        end
      end
    end
  end

  describe ".with_script_context" do
    let(:script) do
      ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, language, extension_point_schema)
    end
    let(:script_file) { "#{extension_point.type}.#{language}" }
    let(:helper_file) { "helper.#{language}" }

    it "should go to a tempdir with all its files" do
      FakeFS.with_fresh do
        FileUtils.mkdir_p(script_source_base)
        Dir.chdir(script_source_base)

        File.write(script_file, "//run code")
        File.write(helper_file, "//helper code")

        FileUtils.mkdir_p("other_dir")

        script_repository.with_script_context(script) do
          assert script_source_base != Dir.pwd
          assert File.exist?(script_file)
          assert File.exist?(helper_file)
        end
      end
    end
  end
end
