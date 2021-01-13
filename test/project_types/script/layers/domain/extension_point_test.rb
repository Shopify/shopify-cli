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

  describe ".new" do
    describe "when deprecation status is not specified" do
      subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }
      it "should construct new, non-deprecated ExtensionPoint" do
        extension_point = subject
        assert_equal type, extension_point.type
        refute extension_point.deprecated?

        sdk = extension_point.sdks[:ts]
        refute_nil sdk.package
        refute_nil sdk.sdk_version
        refute_nil sdk.toolchain_version
      end

      describe "when deprecation status is specified" do
        let(:config_with_deprecation) { config.merge({ "deprecation" => true }) }

        subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }

        it "should construct a deprecated extension point" do
          extension_point = subject
          refute extension_point.deprecated?
        end
      end
    end
  end
end
