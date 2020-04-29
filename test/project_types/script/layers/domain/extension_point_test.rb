# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Domain::ExtensionPoint do
  let(:type) { "discount" }
  let(:config) do
    {
      "assemblyscript" => {
        "package" => "@shopify/extension-point-as-fake",
        "version" => "*",
        "sdk-version" => "*",
      },
    }
  end

  describe ".new" do
    subject { Script::Layers::Domain::ExtensionPoint.new(type, config) }
    it "should construct new ExtensionPoint" do
      extension_point = subject
      assert_equal type, extension_point.type

      sdk = extension_point.sdks[:ts]
      refute_nil sdk.package
      refute_nil sdk.version
      refute_nil sdk.sdk_version
    end
  end
end
