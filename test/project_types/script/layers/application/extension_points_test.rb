# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::ExtensionPoints do
  include TestHelpers::FakeFS

  let(:extension_point_type) { "discount" }
  let(:deprecated_extension_point_type) { "unit_limit_per_order" }
  let(:beta_extension_point_type) { "tax_filter" }
  let(:extension_point_repository) { TestHelpers::FakeExtensionPointRepository.new }
  let(:extension_point) { extension_point_repository.get_extension_point(extension_point_type) }

  before do
    extension_point_repository.create_extension_point(extension_point_type)
    extension_point_repository.create_deprecated_extension_point(deprecated_extension_point_type)
    extension_point_repository.create_beta_extension_point(beta_extension_point_type)
    Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
  end

  describe ".get" do
    describe "when extension point exists" do
      it "should return a valid extension point" do
        ep = Script::Layers::Application::ExtensionPoints.get(type: extension_point_type)
        assert_equal extension_point, ep
      end
    end

    describe "when extension point does not exist" do
      it "should raise InvalidExtensionPointError" do
        assert_raises(Script::Layers::Domain::Errors::InvalidExtensionPointError) do
          Script::Layers::Application::ExtensionPoints.get(type: "invalid")
        end
      end
    end
  end

  describe ".types" do
    it "should return an array of all types" do
      assert_equal %w(discount unit_limit_per_order tax_filter), Script::Layers::Application::ExtensionPoints.types
    end
  end

  describe ".available_types" do
    describe "when beta flag is disabled" do
      before do
        ShopifyCLI::Feature.stubs(:enabled?).with(:scripts_beta_extension_points).returns(false)
      end
      it "should return an array of all ep types that are not deprecated or in beta" do
        assert_equal %w(discount), Script::Layers::Application::ExtensionPoints.available_types
      end
    end

    describe "when beta flag is enabled" do
      before do
        ShopifyCLI::Feature.stubs(:enabled?).with(:scripts_beta_extension_points).returns(true)
      end
      it "should return an array of all ep types that are not deprecated or in beta" do
        assert_equal %w(discount tax_filter), Script::Layers::Application::ExtensionPoints.available_types
      end
    end
  end

  describe ".deprecated_types" do
    it "should return an array of all deprecated types" do
      assert_equal %w(unit_limit_per_order), Script::Layers::Application::ExtensionPoints.deprecated_types
    end
  end

  describe ".all_languages" do
    subject { Script::Layers::Application::ExtensionPoints.all_languages }

    let(:scripts_beta_extension_points) { false }
    let(:scripts_beta_languages) { false }

    before do
      ShopifyCLI::Feature
        .stubs(:enabled?)
        .with(:scripts_beta_languages)
        .returns(scripts_beta_languages)
      ShopifyCLI::Feature
        .stubs(:enabled?)
        .with(:scripts_beta_extension_points)
        .returns(scripts_beta_extension_points)
    end

    describe "when beta language flag is enabled" do
      let(:scripts_beta_languages) { true }

      it "returns a list of all languages implemented by non beta extension points" do
        assert_equal ["assemblyscript", "rust", "wasm"], subject
      end
    end

    describe "when beta extension_points is enabled" do
      let(:scripts_beta_extension_points) { true }

      it "returns a list of non-beta languages implemented by all extension points" do
        assert_equal ["assemblyscript", "tinygo"], subject
      end
    end

    describe "when beta language and extension points flags are enabled" do
      let(:scripts_beta_languages) { true }
      let(:scripts_beta_extension_points) { true }

      it "returns a list of all languages implemented by all extension points" do
        assert_equal ["assemblyscript", "rust", "wasm", "tinygo"], subject
      end
    end

    describe "when beta language and extension points flags are disabled" do
      let(:scripts_beta_languages) { false }
      let(:scripts_beta_extension_points) { false }

      it "returns a list of non-beta languages implemented by non beta extension points" do
        assert_equal ["assemblyscript"], subject
      end
    end
  end

  describe ".languages" do
    let(:type) { extension_point_type }
    subject { Script::Layers::Application::ExtensionPoints.languages(type: type) }

    describe "when ep does not exist" do
      let(:type) { "imaginary" }

      it "should raise InvalidExtensionPointError" do
        assert_raises(Script::Layers::Domain::Errors::InvalidExtensionPointError) { subject }
      end
    end

    describe "when beta language flag is enabled" do
      before do
        ShopifyCLI::Feature.stubs(:enabled?).with(:scripts_beta_languages).returns(true)
      end

      it "should return all languages" do
        assert_equal ["assemblyscript", "rust", "wasm"], subject
      end
    end

    describe "when beta language flag is not enabled" do
      before do
        ShopifyCLI::Feature.stubs(:enabled?).with(:scripts_beta_languages).returns(false)
      end

      it "should return only fully supported languages" do
        assert_equal ["assemblyscript"], subject
      end
    end
  end

  describe ".supported_language?" do
    let(:type) { extension_point_type }
    let(:language) { "assemblyscript" }
    subject { Script::Layers::Application::ExtensionPoints.supported_language?(type: type, language: language) }

    describe "when ep does not exist" do
      let(:type) { "imaginary" }

      it "should raise InvalidExtensionPointError" do
        assert_raises(Script::Layers::Domain::Errors::InvalidExtensionPointError) { subject }
      end
    end

    describe "when beta language flag is enabled" do
      before do
        ShopifyCLI::Feature.stubs(:enabled?).with(:scripts_beta_languages).returns(true)
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
        ShopifyCLI::Feature.stubs(:enabled?).with(:scripts_beta_languages).returns(false)
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
