# frozen_string_literal: true

require "test_helper"

ShopifyCli::ProjectType.load_type(:script)

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
      puts sdk.inspect
      refute_nil sdk.package
      refute_nil sdk.version
      refute_nil sdk.sdk_version
    end
  end
end
