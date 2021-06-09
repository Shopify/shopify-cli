# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::ScriptApis do
  include TestHelpers::FakeFS

  let(:script_name) { "name" }
  let(:script_api_type) { "discount" }
  let(:deprecated_script_api_type) { "unit_limit_per_order" }
  let(:beta_script_api_type) { "tax_filter" }
  let(:script_api_repository) { TestHelpers::FakeScriptApiRepository.new }
  let(:script_api) { script_api_repository.get(script_api_type) }

  before do
    script_api_repository.create_script_api(script_api_type)
    script_api_repository.create_deprecated_script_api(deprecated_script_api_type)
    script_api_repository.create_beta_script_api(beta_script_api_type)
    Script::Layers::Infrastructure::ScriptApiRepository.stubs(:new).returns(script_api_repository)
  end

  describe ".get" do
    describe "when extension point exists" do
      it "should return a valid extension point" do
        ep = Script::Layers::Application::ScriptApis.get(type: script_api_type)
        assert_equal script_api, ep
      end
    end

    describe "when extension point does not exist" do
      it "should raise InvalidScriptApiError" do
        assert_raises(Script::Layers::Domain::Errors::InvalidScriptApiError) do
          Script::Layers::Application::ScriptApis.get(type: "invalid")
        end
      end
    end
  end

  describe ".types" do
    it "should return an array of all types" do
      assert_equal %w(discount unit_limit_per_order tax_filter), Script::Layers::Application::ScriptApis.types
    end
  end

  describe ".available_types" do
    it "should return an array of all ep types that are not deprecated or in beta" do
      assert_equal %w(discount), Script::Layers::Application::ScriptApis.available_types
    end
  end

  describe ".deprecated_types" do
    it "should return an array of all deprecated types" do
      assert_equal %w(unit_limit_per_order), Script::Layers::Application::ScriptApis.deprecated_types
    end
  end

  describe ".languages" do
    let(:type) { script_api_type }
    subject { Script::Layers::Application::ScriptApis.languages(type: type) }

    describe "when ep does not exist" do
      let(:type) { "imaginary" }

      it "should raise InvalidScriptApiError" do
        assert_raises(Script::Layers::Domain::Errors::InvalidScriptApiError) { subject }
      end
    end

    describe "when beta language flag is enabled" do
      before do
        ShopifyCli::Feature.expects(:enabled?).with(:scripts_beta_languages).returns(true).at_least_once
      end

      it "should return all languages" do
        assert_equal ["assemblyscript", "rust"], subject
      end
    end

    describe "when beta language flag is not enabled" do
      before do
        ShopifyCli::Feature.expects(:enabled?).with(:scripts_beta_languages).returns(false).at_least_once
      end

      it "should return only fully supported languages" do
        assert_equal ["assemblyscript"], subject
      end
    end
  end

  describe ".supported_language?" do
    let(:type) { script_api_type }
    let(:language) { "assemblyscript" }
    subject { Script::Layers::Application::ScriptApis.supported_language?(type: type, language: language) }

    describe "when ep does not exist" do
      let(:type) { "imaginary" }

      it "should raise InvalidScriptApiError" do
        assert_raises(Script::Layers::Domain::Errors::InvalidScriptApiError) { subject }
      end
    end

    describe "when beta language flag is enabled" do
      before do
        ShopifyCli::Feature.expects(:enabled?).with(:scripts_beta_languages).returns(true).at_least_once
      end

      describe "when asking about supported language" do
        let(:language) { "assemblyscript" }

        it "should return true" do
          assert subject
        end
      end

      describe "when asking about beta language" do
        let(:language) { "rust" }

        it "should return true" do
          assert subject
        end
      end

      describe "when user capitalizes supported language" do
        let(:language) { "Rust" }

        it "should return true" do
          assert subject
        end
      end

      describe "when asking about unsupported language" do
        let(:language) { "english" }

        it "should return false" do
          refute subject
        end
      end
    end

    describe "when beta language flag is not enabled" do
      before do
        ShopifyCli::Feature.expects(:enabled?).with(:scripts_beta_languages).returns(false).at_least_once
      end

      describe "when asking about supported language" do
        let(:language) { "assemblyscript" }

        it "should return true" do
          assert subject
        end
      end

      describe "when asking about beta language" do
        let(:language) { "rust" }

        it "should return false" do
          refute subject
        end
      end

      describe "when user capitalizes supported language" do
        let(:language) { "AssemblyScript" }

        it "should return true" do
          assert subject
        end
      end

      describe "when asking about unsupported language" do
        let(:language) { "english" }

        it "should return false" do
          refute subject
        end
      end
    end
  end
end
