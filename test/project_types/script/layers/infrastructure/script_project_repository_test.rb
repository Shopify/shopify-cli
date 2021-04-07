# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_config_ui_repository"

describe Script::Layers::Infrastructure::ScriptProjectRepository do
  include TestHelpers::FakeFS

  let(:ctx) { TestHelpers::FakeContext.new }
  let(:instance) { Script::Layers::Infrastructure::ScriptProjectRepository.new(ctx: ctx) }

  let(:config_ui_repository) { Script::Layers::Infrastructure::FakeConfigUiRepository.new }
  let(:deprecated_ep_types) { [] }
  let(:supported_languages) { ['assemblyscript'] }

  before do
    Script::Layers::Infrastructure::ConfigUiRepository.stubs(:new).returns(config_ui_repository)
    Script::Layers::Application::ExtensionPoints.stubs(:deprecated_types).returns(deprecated_ep_types)
    Script::Layers::Application::ExtensionPoints.stubs(:languages).returns(supported_languages)
  end

  describe "#create" do
    let(:script_name) { "script_name" }
    let(:extension_point_type) { "tax_filter" }
    let(:language) { 'assemblyscript' }
    let(:no_config_ui) { false }

    subject do
      instance.create(
        script_name: script_name,
        extension_point_type: extension_point_type,
        language: language,
        no_config_ui: no_config_ui
      )
    end

    describe "when another project with this name already exists" do
      it "should raise ScriptProjectAlreadyExistsError" do
        ctx.mkdir_p(script_name)
        assert_raises(Script::Layers::Infrastructure::Errors::ScriptProjectAlreadyExistsError) { subject }
      end
    end

    def it_should_create_a_new_script_project
      initial_dir = ctx.root
      refute ctx.dir_exist?(script_name)

      capture_io { subject }

      assert_equal ctx.root, File.join(initial_dir, script_name)

      assert_equal ctx.root, subject.id
      assert_nil subject.env
      assert_equal script_name, subject.script_name
      assert_equal extension_point_type, subject.extension_point_type
      assert_equal language, subject.language
    end

    describe "when no_config_ui is false" do
      let(:no_config_ui) { false }
      let(:expected_config_ui_filename) { "config-ui.yml" }
      let(:expected_config_ui_content) do
        "---\nversion: 1\ntype: single\ntitle: #{script_name}\ndescription: ''\nfields: []\n"
      end

      it "should create a new script project" do
        it_should_create_a_new_script_project
      end

      it "should create a config_ui_file" do
        capture_io { subject }

        config_ui = config_ui_repository.get_config_ui(expected_config_ui_filename)

        refute_nil config_ui
        assert_equal expected_config_ui_filename, config_ui.filename
        assert_equal expected_config_ui_content, config_ui.content
        assert_equal config_ui, subject.config_ui
        assert_equal expected_config_ui_filename, ShopifyCli::Project.current.config["config_ui_file"]
      end
    end

    describe "when no_config_ui is true" do
      let(:no_config_ui) { true }
      let(:expected_config_ui_filename) { nil }

      it "should create a new script project" do
        it_should_create_a_new_script_project
      end

      it "should not create a config_ui_file" do
        capture_io { subject }

        assert_nil subject.config_ui
        assert_nil ShopifyCli::Project.current.config["config_ui_file"]
      end
    end
  end

  describe "#delete" do
    subject { instance.delete }

    describe "when directory is not within a script project" do
      it "should do nothing" do
        initial_dir = ctx.root
        ctx.expects(:rm_r).never
        assert_nil subject
        assert_equal initial_dir, ctx.root
      end
    end

    describe "when directory is in a script project" do
      let(:script_name) { 'script_name' }

      before do
        instance.create(
          script_name: script_name,
          extension_point_type: 'discount',
          language: 'assemblyscript',
          no_config_ui: false
        )
      end

      it "should remove the project directory" do
        initial_dir = ctx.root
        subject
        assert_equal File.join(initial_dir, "../"), ctx.root
        refute File.exists?(File.join(initial_dir, script_name))
      end
    end
  end

  describe "#get" do
    subject { instance.get }

    let(:script_name) { 'script_name' }
    let(:extension_point_type) { 'tax_filter' }
    let(:language) { 'assemblyscript' }

    before do
      instance.create(
        script_name: script_name,
        extension_point_type: extension_point_type,
        language: language,
        no_config_ui: false
      )
    end

    describe "when project config is valid" do
      it "should return the ScriptProject" do
        assert_equal ctx.root, subject.id
        assert_nil subject.env
        assert_equal script_name, subject.script_name
        assert_equal extension_point_type, subject.extension_point_type
        assert_equal language, subject.language
        refute_nil subject.config_ui
      end
    end

    describe "when extension point is deprecated" do
      let(:deprecated_ep_types) { [extension_point_type] }

      it "should raise DeprecatedEPError" do
        assert_raises(Script::Layers::Infrastructure::Errors::DeprecatedEPError) { subject }
      end
    end

    describe "when language is not supported" do
      let(:supported_languages) { ['rust'] }

      it "should raise DeprecatedEPError" do
        assert_raises(Script::Layers::Infrastructure::Errors::InvalidLanguageError) { subject }
      end
    end

    describe "when project is missing metadata" do
      let(:valid_config) do
        {
          "extension_point_type" => 'tax_filter',
          "script_name" => 'script_name',
          "config_ui_file" => 'config-ui.yml',
        }
      end
      let(:actual_config) { valid_config }

      before do
        ShopifyCli::Project.any_instance.stubs(:config).returns(actual_config)
      end

      describe "when missing extension_point_type" do
        let(:actual_config) { valid_config.slice("config_ui_file", "script_name") }

        it "should raise InvalidContextError" do
          assert_raises(Script::Layers::Infrastructure::Errors::InvalidContextError) { subject }
        end
      end

      describe "when missing script_name" do
        let(:actual_config) { valid_config.slice("extension_point_type", "config_ui_file") }

        it "should raise InvalidContextError" do
          assert_raises(Script::Layers::Infrastructure::Errors::InvalidContextError) { subject }
        end
      end

      describe "when missing config_ui_file" do
        let(:actual_config) { valid_config.slice("extension_point_type", "script_name") }

        it "should succeed" do
          assert subject
        end
      end
    end
  end
end
