# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::ConfigurationRepository do
  let(:extension_point) { ShopifyCli::ScriptModule::Domain::ExtensionPoint.new("discount", "schema", "types", "example") }
  let(:script) do
    config = MiniTest::Mock.new
    ShopifyCli::ScriptModule::Domain::Script.new("discount_script", extension_point, config, "ts", "schema")
  end
  let(:configuration_root) do
    source_path = ShopifyCli::ScriptModule::Infrastructure::Repository::SOURCE_PATH
    "#{source_path}/#{extension_point.type}/#{script.name}/configuration"
  end
  let(:schema_file) { "#{configuration_root}/configuration.schema" }
  let(:glue_code_file) { "#{configuration_root}/configuration.#{script.language}" }

  let(:configuration_schema_template) do
    installation_path = ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH
    "#{installation_path}/templates/configuration/configuration.schema"
  end

  let(:configuration_schema) do
    <<~GRAPHQL
      input Configuration {
        _: Boolean
      }

      type Query {
        configuration: Configuration
      }
    GRAPHQL
  end

  let(:configuration) do
    ShopifyCli::ScriptModule::Domain::Configuration.new(schema_file, "config.schema", configuration_schema, "code")
  end

  let(:configuration_repository) { ShopifyCli::ScriptModule::Infrastructure::ConfigurationRepository.new }

  describe ".create_configuration" do
    subject { configuration_repository.create_configuration(extension_point, script.name) }

    it "should a configuration" do
      FakeFS.with_fresh do
        FakeFS::FileSystem.clone(configuration_schema_template)
        assert_equal configuration_root, subject.id
        assert File.directory?(configuration_root)
        assert File.exist?(schema_file)
      end
    end
  end

  describe ".get_configuration" do
    subject { configuration_repository.get_configuration(extension_point.type, script.name) }

    describe "when configuration.schema file exists" do
      it "should return a configuration" do
        FakeFS.with_fresh do
          FakeFS::FileSystem.clone(configuration_schema_template)
          FileUtils.mkdir_p(configuration_root)
          FileUtils.cp_r(configuration_schema_template, configuration_root)
          assert_equal configuration_root, subject.id
        end
      end
    end

    describe "when configuration.schema file does not exist" do
      it "should raise ConfigurationFileNotFoundError" do
        FakeFS.with_fresh do
          FileUtils.mkdir_p(configuration_root)
          assert_raises(ShopifyCli::ScriptModule::Domain::ConfigurationFileNotFoundError) { subject }
        end
      end
    end
  end

  describe ".update_configuration" do
    let(:schema_name) { "configuration.schema" }
    let(:glue_code) { "int i" }
    let(:configuration) { ShopifyCli::ScriptModule::Domain::Configuration.new(configuration_root, schema_name, configuration_schema, glue_code) }

    subject { configuration_repository.update_configuration(configuration) }
    it "should write the glue_code file" do
      FakeFS.with_fresh do
        FileUtils.mkdir_p(configuration_root)
        subject
        assert_equal glue_code, File.read(glue_code_file)
      end
    end
  end
end
