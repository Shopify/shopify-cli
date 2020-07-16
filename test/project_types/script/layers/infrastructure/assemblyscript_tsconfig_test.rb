# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Infrastructure::AssemblyScriptTsConfig do
  let(:dir_to_write_in) { "foo" }

  subject { Script::Layers::Infrastructure::AssemblyScriptTsConfig.new(dir_to_write_in: dir_to_write_in) }

  describe ".with_extends_assemblyscript_config" do
    let(:relative_path_to_node_modules) { "." }

    before(:each) do
      pathname_stub = stub
      pathname_stub.stubs(:relative_path_from).with(dir_to_write_in).returns("..")
      Pathname.stubs(:new).with(relative_path_to_node_modules).returns(pathname_stub)
    end

    it "should set extends correctly" do
      subject
        .with_extends_assemblyscript_config(relative_path_to_node_modules: relative_path_to_node_modules)

      assert_equal({ extends: "../node_modules/assemblyscript/std/assembly.json" }, subject.config)
    end

    it "should return itself" do
      ret_val = subject.with_extends_assemblyscript_config(relative_path_to_node_modules: relative_path_to_node_modules)
      assert_equal subject, ret_val
    end
  end

  describe ".with_module_resolution_paths" do
    it "should set compiler options with paths member" do
      subject.with_module_resolution_paths(paths: { "*": "../bar" })

      assert_equal({ compilerOptions: { baseUrl: ".", paths: { "*": "../bar" } } }, subject.config)
    end

    it "should return itself" do
      assert_equal subject, subject.with_module_resolution_paths(paths: {})
    end
  end

  describe ".write" do
    before do
      @context.mkdir_p(dir_to_write_in)
    end

    it "should write the config" do
      subject.write
      assert_equal "{\n}", File.read("#{dir_to_write_in}/tsconfig.json")
    end
  end
end
