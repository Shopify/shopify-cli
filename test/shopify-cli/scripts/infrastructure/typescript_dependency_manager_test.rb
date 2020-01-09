# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::TypeScriptDependencyManager do
  let(:script_name) { "foo_discount_script" }
  let(:language) { "ts" }
  let(:ctx) { TestHelpers::FakeContext.new }
  let(:ts_dep_manager) do
    ShopifyCli::ScriptModule::Infrastructure::TypeScriptDependencyManager.new(ctx, script_name, language)
  end

  describe ".installed?" do
    subject { ts_dep_manager.installed? }

    it "should return true if node_modules folder exists" do
      FakeFS.with_fresh do
        FileUtils.mkdir_p("node_modules")
        assert_equal true, subject
      end
    end

    it "should return false if node_modules folder does not exists" do
      FakeFS.with_fresh do
        assert_equal false, subject
      end
    end
  end

  describe ".install" do
    subject { ts_dep_manager.install }

    it "should install using npm with the generated package.json" do
      ShopifyCli::Tasks::JsDeps.expects(:call).with(ctx)
      FakeFS.with_fresh do
        subject
        assert File.exist?("package.json")
      end
    end
  end
end
