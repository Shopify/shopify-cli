# frozen_string_literal: true

require 'project_types/script/test_helper'

module Script
  class ScriptProjectTest < MiniTest::Test
    def setup
      @context = TestHelpers::FakeContext.new
      @script_name = 'name'
    end

    def test_cleanup_when_directory_exists
      Dir
        .expects(:exist?)
        .with("#{@context.root}/#{@script_name}")
        .returns(true)

      @context
        .expects(:rm_r)
        .with("#{@context.root}/#{@script_name}")

      Script::ScriptProject.cleanup(
        ctx: @context,
        script_name: @script_name,
        root_dir: @context.root
      )
    end

    def test_cleanup_when_directory_does_not_exist
      Dir
        .expects(:exist?)
        .with("#{@context.root}/#{@script_name}")
        .returns(false)

      Script::ScriptProject.cleanup(
        ctx: @context,
        script_name: @script_name,
        root_dir: @context.root
      )
    end
  end
end
