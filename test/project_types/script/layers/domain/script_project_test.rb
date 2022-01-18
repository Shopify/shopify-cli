# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::ScriptProject do
  let(:id) { "id" }
  let(:env) { ShopifyCLI::Resources::EnvFile.new(api_key: "1234", secret: "shh") }
  let(:extension_point_type) { "discount" }
  let(:script_name) { "foo_script" }
  let(:language) { "assemblyscript" }
  let(:script_config_filename) { "script.config.yml" }
  let(:script_config) do
    Script::Layers::Domain::ScriptConfig.new(
      content: script_config_content,
      filename: script_config_filename,
    )
  end
  let(:script_config_content) do
    {
      "version" => "1",
      "title" => script_name,
    }
  end

  describe ".new" do
    subject { Script::Layers::Domain::ScriptProject.new(**args) }

    let(:all_args) do
      {
        id: id,
        env: env,
        extension_point_type: extension_point_type,
        script_name: script_name,
        language: language,
        script_config: script_config,
      }
    end
    let(:args) { all_args }

    it "should set monorail metadata" do
      subject
      assert_equal({
        "script_name" => script_name,
        "extension_point_type" => extension_point_type,
        "language" => language,
      }, ShopifyCLI::Core::Monorail.metadata)
    end

    describe "when all properties are present" do
      it "should create the entity" do
        assert_equal id, subject.id
        assert_equal env, subject.env
        assert_equal extension_point_type, subject.extension_point_type
        assert_equal script_name, subject.script_name
        assert_equal language, subject.language
        assert_equal script_config, subject.script_config
      end
    end

    describe "when optional properties are missing" do
      let(:args) { all_args.slice(:id, :extension_point_type, :script_name, :language) }

      it "should create the entity" do
        assert_equal id, subject.id
        assert_nil subject.env
        assert_equal extension_point_type, subject.extension_point_type
        assert_equal script_name, subject.script_name
        assert_equal language, subject.language
        assert_nil subject.script_config
      end
    end

    describe "when required properties are missing" do
      let(:args) { all_args.slice(:env, :script_config) }

      it "should raise" do
        assert_raises(SmartProperties::InitializationError) { subject }
      end
    end
  end
end
