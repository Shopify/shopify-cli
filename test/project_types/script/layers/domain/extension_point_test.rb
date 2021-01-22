# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::ExtensionPoint do
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
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }
      it "should construct new, non-deprecated ExtensionPoint" do
        extension_point = subject
        assert_equal type, extension_point.type
        refute extension_point.deprecated?

        sdk = extension_point.sdks.assemblyscript
        refute_nil sdk.package
        refute_nil sdk.sdk_version
        refute_nil sdk.toolchain_version
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

    describe "when multiple sdks are implemented" do
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config_with_rust) }
      it "should construct new, non-deprecated ExtensionPoint" do
        extension_point = subject
        assert_equal type, extension_point.type
        refute extension_point.deprecated?

        assert_equal 2, extension_point.sdks.all.count
        as_sdk = extension_point.sdks.assemblyscript
        assert_equal "assemblyscript", as_sdk.language
        refute_nil as_sdk.package
        refute_nil as_sdk.sdk_version
        refute_nil as_sdk.toolchain_version
        refute as_sdk.beta?

        rs_sdk = extension_point.sdks.rust
        assert_equal "rust", rs_sdk.language
        refute_nil rs_sdk.package
        assert rs_sdk.beta?
      end
    end

    describe "when some sdk is not implemented" do
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }

      it "should return nil for that sdk" do
        extension_point = subject

        assert_equal 1, extension_point.sdks.all.count
        as_sdk = extension_point.sdks.assemblyscript
        assert_equal "assemblyscript", as_sdk.language
        refute_nil as_sdk.package
        refute_nil as_sdk.sdk_version
        refute_nil as_sdk.toolchain_version
        refute as_sdk.beta?

        assert_nil extension_point.sdks.rust
      end
    end
  end
end
