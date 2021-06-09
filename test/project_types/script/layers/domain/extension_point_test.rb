# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::ScriptApi do
  let(:type) { "discount" }
  let(:config) do
    {
      "assemblyscript" => {
        "package" => "@shopify/extension-point-as-fake",
        "sdk-version" => "*",
        "toolchain-version" => "*",
      },
    }
  end
  let(:config_with_rust) do
    config.merge({
      "rust" => {
        "beta" => true,
        "package" => "@shopify/extension-point-rs-fake",
        "sdk-version" => "*",
        "toolchain-version" => "*",
      },
    })
  end

  describe ".new" do
    describe "when deprecation status is not specified" do
      subject { Script::Layers::Domain::ScriptApi.new(type, config) }
      it "should construct new, non-deprecated ScriptApi" do
        script_api = subject
        assert_equal type, script_api.type
        refute script_api.deprecated?

        sdk = script_api.sdks.assemblyscript
        refute_nil sdk.package
        refute_nil sdk.sdk_version
        refute_nil sdk.toolchain_version
      end
    end

    describe "when deprecation status is specified" do
      let(:config_with_deprecation) { config.merge({ "deprecated" => true }) }

      subject { Script::Layers::Domain::ScriptApi.new(type, config_with_deprecation) }

      it "should construct a deprecated extension point" do
        script_api = subject
        assert script_api.deprecated?
      end
    end

    describe "when a domain is not specified" do
      subject { Script::Layers::Domain::ScriptApi.new(type, config) }
      it "should construct a non-bounded extension point" do
        assert_nil subject.domain
      end
    end

    describe "when a domain is specified" do
      let(:config_with_domain) { config.merge({ "domain" => "checkout" }) }
      subject { Script::Layers::Domain::ScriptApi.new(type, config_with_domain) }
      it "should construct a bounded extension point" do
        assert_equal "checkout", subject.domain
      end
    end

    describe ".dasherize_type" do
      it "should replace all underscore occurrences with a dash" do
        script_api = Script::Layers::Domain::ScriptApi.new("foo_bar_baz", config)
        assert_equal "foo-bar-baz", script_api.dasherize_type
        script_api = Script::Layers::Domain::ScriptApi.new("foo", config)
        assert_equal "foo", script_api.dasherize_type
      end
    end

    describe "when multiple sdks are implemented" do
      subject { Script::Layers::Domain::ScriptApi.new(type, config_with_rust) }
      it "should construct new, non-deprecated ScriptApi" do
        script_api = subject
        assert_equal type, script_api.type
        refute script_api.deprecated?

        assert_equal 2, script_api.sdks.all.count
        as_sdk = script_api.sdks.assemblyscript
        assert_equal "assemblyscript", as_sdk.class.language
        refute_nil as_sdk.package
        refute_nil as_sdk.sdk_version
        refute_nil as_sdk.toolchain_version
        refute as_sdk.beta?

        rs_sdk = script_api.sdks.rust
        assert_equal "rust", rs_sdk.class.language
        refute_nil rs_sdk.package
        assert rs_sdk.beta?
      end
    end

    describe "when some sdk is not implemented" do
      subject { Script::Layers::Domain::ScriptApi.new(type, config) }

      it "should return nil for that sdk" do
        script_api = subject

        assert_equal 1, script_api.sdks.all.count
        as_sdk = script_api.sdks.assemblyscript
        assert_equal "assemblyscript", as_sdk.class.language
        refute_nil as_sdk.package
        refute_nil as_sdk.sdk_version
        refute_nil as_sdk.toolchain_version
        refute as_sdk.beta?

        assert_nil script_api.sdks.rust
      end
    end
  end
end
