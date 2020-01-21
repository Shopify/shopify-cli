require "test_helper"
require_relative "fake_script_repository"

describe ShopifyCli::ScriptModule::Infrastructure::TestSuiteRepository do
  include TestHelpers::FakeFS

  let(:extension_point_type) { "discount" }
  let(:extension_point) do
    ShopifyCli::ScriptModule::Domain::ExtensionPoint.new(extension_point_type, "schema", "types", "example")
  end
  let(:script_name) { "myscript" }
  let(:context) { TestHelpers::FakeContext.new }
  let(:language) { "ts" }
  let(:script) { ShopifyCli::ScriptModule::Domain::Script.new(script_name, extension_point, language, "schema") }
  let(:template_base) { "#{ShopifyCli::ScriptModule::Infrastructure::Repository::INSTALLATION_BASE_PATH}/templates" }
  let(:template_file) do
    "#{template_base}/ts/#{ShopifyCli::ScriptModule::Infrastructure::TestSuiteRepository::TEST_TEMPLATE_NAME}"\
    ".spec.#{language}"
  end
  let(:config_file) { "#{template_base}/ts/as-pect.config.js" }
  let(:spec_test_base) do
    "#{format(ShopifyCli::ScriptModule::Infrastructure::Repository::FOLDER_PATH_TEMPLATE, script_name: script_name)}"\
    "/test"
  end
  let(:spec_test_file) { "#{spec_test_base}/#{script_name}.spec.#{language}" }
  let(:script_repository) { ShopifyCli::ScriptModule::Infrastructure::FakeScriptRepository.new }
  let(:repository) { ShopifyCli::ScriptModule::Infrastructure::TestSuiteRepository.new }

  before do
    ShopifyCli::ScriptModule::Infrastructure::ScriptRepository
      .stubs(:new)
      .returns(script_repository)
  end

  describe ".create_test_suite" do
    subject { repository.create_test_suite(script) }

    it "should create a test suite" do
      FakeFS::FileSystem.clone(template_file)
      FakeFS::FileSystem.clone(config_file)
      test_suite = subject
      assert File.exist?(spec_test_file)
      assert_equal spec_test_file, test_suite.id
      assert_equal script, test_suite.script
    end
  end

  describe ".get_test_suite" do
    subject { repository.get_test_suite(context, language, extension_point_type, script_name) }

    describe "when script is valid" do
      before do
        script_repository.create_script(language, extension_point, script_name)
      end

      it "should return the requested test suite if test spec file exists" do
        FileUtils.mkdir_p(spec_test_base)
        File.open(spec_test_file, "w") do |file|
          file.puts "//test code"
        end

        test_suite = subject
        assert_equal spec_test_file, test_suite.id
      end

      it "should raise TestSuiteNotFoundError if test spec file does not exist" do
        assert_raises(ShopifyCli::ScriptModule::Domain::TestSuiteNotFoundError) { subject }
      end
    end

    describe "when script does not exist" do
      it "should raise ScriptNotFoundError" do
        FileUtils.mkdir_p(spec_test_base)
        File.open(spec_test_file, "w") do |file|
          file.puts "//test code"
        end

        assert_raises(ShopifyCli::ScriptModule::Domain::ScriptNotFoundError) { subject }
      end
    end
  end

  describe ".with_test_suite_context" do
    let(:spec) { ShopifyCli::ScriptModule::Domain::TestSuite.new(spec_test_file, script) }

    it "should allow execution at the correct place within the filesystem" do
      FileUtils.mkdir_p(spec_test_base)
      repository.with_test_suite_context(spec) do
        assert_equal Pathname.new(spec_test_base).cleanpath.to_s, Dir.pwd
      end
    end
  end
end
