# frozen_string_literal: true

require "test_helper"

describe ShopifyCli::ScriptModule::Infrastructure::TypeScriptDependencyManager do
  let(:script_name) { "foo_discount_script" }
  let(:language) { "ts" }
  let(:ts_dep_manager) do
    ShopifyCli::ScriptModule::Infrastructure::TypeScriptDependencyManager.new(script_name, language)
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
    before do
      FakeFS.with_fresh do
        FileUtils.mkdir(script_name)
      end
    end

    describe "when npm exists" do
      before do
        ts_dep_manager.stubs(:system).with('npm --version > /dev/null').returns(true)
        ts_dep_manager.expects(:write_package_json)
      end

      it "should copy over package.json and run npm install if npm exists" do
        ts_dep_manager.expects(:system).with('npm install --no-audit --no-optional').returns(true)
        subject
      end

      it "should abort if installation of packages failed but npm exists" do
        ts_dep_manager.expects(:system).with('npm install --no-audit --no-optional').returns(false)
        assert_raises(ShopifyCli::Abort) { subject }
      end
    end

    it "should abort if npm is not present" do
      ts_dep_manager.stubs(:system).returns(false)
      assert_raises(ShopifyCli::Abort) { subject }
    end
  end
end