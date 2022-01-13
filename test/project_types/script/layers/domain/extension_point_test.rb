# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::ExtensionPoint do
  let(:type) { "discount" }
  let(:config) do
    {
      "libraries" => {
        "assemblyscript" => {
          "package" => "@shopify/extension-point-as-fake",
        },
        "typescript" => {
          "package" => "@shopify/extension-point-ts-fake",
        },
      },
    }
  end
  let(:config_with_rust) do
    {
      "libraries" => {
        "assemblyscript" => {
          "package" => "@shopify/extension-point-as-fake",
        },
        "typescript" => {
          "package" => "@shopify/extension-point-ts-fake",
        },
        "rust" => {
          "beta" => true,
          "package" => "@shopify/extension-point-rs-fake",
        },
      },
    }
  end

  describe ".new" do
    before do
      ShopifyCLI::Feature.stubs(:enabled?).with(:scripts_beta_languages).returns(false)
    end

    describe "when deprecation status is not specified" do
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }
      it "should construct new, non-deprecated ExtensionPoint" do
        extension_point = subject
        assert_equal type, extension_point.type
        refute extension_point.deprecated?
      end
    end

    describe "when deprecation status is specified" do
      let(:config_with_deprecation) { config.merge({ "deprecated" => true }) }

      subject { Script::Layers::Domain::ExtensionPoint.new(type, config_with_deprecation) }

      it "should construct a deprecated extension point" do
        extension_point = subject
        assert extension_point.deprecated?
      end
    end

    describe "when beta status is not specified" do
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }
      it "should construct new, non-deprecated ExtensionPoint" do
        refute subject.beta?
        assert subject.stable?
      end
    end

    describe "when beta status is specified" do
      let(:config_with_deprecation) { config.merge({ "beta" => true }) }

      subject { Script::Layers::Domain::ExtensionPoint.new(type, config_with_deprecation) }

      it "should construct a deprecated extension point" do
        assert subject.beta?
        refute subject.stable?
      end
    end

    describe "when a domain is not specified" do
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }
      it "should construct a non-bounded extension point" do
        assert_nil subject.domain
      end
    end

    describe "when a domain is specified" do
      let(:config_with_domain) { config.merge({ "domain" => "checkout" }) }
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config_with_domain) }
      it "should construct a bounded extension point" do
        assert_equal "checkout", subject.domain
      end
    end

    describe ".dasherize_type" do
      it "should replace all underscore occurrences with a dash" do
        extension_point = Script::Layers::Domain::ExtensionPoint.new("foo_bar_baz", config)
        assert_equal "foo-bar-baz", extension_point.dasherize_type
        extension_point = Script::Layers::Domain::ExtensionPoint.new("foo", config)
        assert_equal "foo", extension_point.dasherize_type
      end
    end

    describe ".libraries" do
      describe "when multiple libraries are implemented" do
        subject { Script::Layers::Domain::ExtensionPoint.new(type, config_with_rust) }
        it "should return all the implemented libraries" do
          extension_point = subject
          assert_equal 3, extension_point.libraries.all.count
          refute_nil extension_point.libraries.for("assemblyscript")
          refute_nil extension_point.libraries.for("rust")
        end
      end

      describe "when a library is not implemented" do
        subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }

        it "should not return that library" do
          extension_point = subject

          assert_equal 2, extension_point.libraries.all.count
          assert_nil extension_point.libraries.for("rust")
        end
      end
    end

    describe ".library_languages" do
      let(:ep) { Script::Layers::Domain::ExtensionPoint.new(type, config_with_rust) }
      subject { ep.library_languages(include_betas: include_betas) }

      describe "include_betas argument is true" do
        let(:include_betas) { true }

        it "returns all the languages of the libraries" do
          assert_equal 3, subject.count
          assert_includes subject, "assemblyscript"
          assert_includes subject, "typescript"
          assert_includes subject, "rust"
        end
      end

      describe "include_betas argument is false" do
        let(:include_betas) { false }

        it "returns only non-beta languages of the libraries" do
          assert_equal 2, subject.count
          assert_includes subject, "assemblyscript"
          assert_includes subject, "typescript"
        end
      end
    end

    describe "when scripts_beta_languages flag is disabled" do
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }

      before do
        ShopifyCLI::Feature.stubs(:enabled?).with(:scripts_beta_languages).returns(false)
      end

      it "should not return other as a language" do
        extension_point = subject
        assert_nil extension_point.libraries.for("other")
      end
    end

    describe "when scripts_beta_languages flag is enabled" do
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }

      before do
        ShopifyCLI::Feature.stubs(:enabled?).with(:scripts_beta_languages).returns(true)
      end

      it "should return other as a language" do
        extension_point = subject
        refute_nil extension_point.libraries.for("other")
      end
    end
  end
end
