# frozen_string_literal: true

require 'project_types/script/test_helper'

module Script
  class ScriptProjectTest < MiniTest::Test
    def setup
      super
      @context = TestHelpers::FakeContext.new
      @script_name = 'name'
      @extension_point_type = 'ep_type'
    end

    def test_initialize
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with('.shopify-cli.yml')
        .returns({
          'extension_point_type' => @extension_point_type,
          'script_name' => @script_name,
        })

      ScriptProject.new(directory: 'testdir')

      assert_equal({
        "script_name" => @script_name,
        "extension_point_type" => @extension_point_type,
        "language" => 'AssemblyScript',
      }, ShopifyCli::Core::Monorail.metadata)
    end

    def test_initialize_with_deprecated_ep
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with('.shopify-cli.yml')
        .returns({
          'extension_point_type' => @extension_point_type,
          'script_name' => @script_name,
        })

      Script::Layers::Application::ExtensionPoints.stubs(:deprecated_types).returns([@extension_point_type])

      assert_raises Errors::DeprecatedEPError do
        ScriptProject.new(directory: 'testdir')
      end
    end

    def test_create_when_directory_does_not_exist
      @context
        .expects(:dir_exist?)
        .with(@script_name)
        .returns(false)

      @context
        .expects(:mkdir_p)
        .with(@script_name)

      @context
        .expects(:chdir)
        .with(@script_name)

      Script::ScriptProject.create(@context, @script_name)
    end

    def test_create_when_directory_exists
      @context
        .expects(:dir_exist?)
        .with(@script_name)
        .returns(true)

      assert_raises Errors::ScriptProjectAlreadyExistsError do
        Script::ScriptProject.create(@context, @script_name)
      end
    end

    def test_cleanup_when_directory_exists
      @context
        .expects(:chdir)
        .with(@context.root)

      @context
        .expects(:dir_exist?)
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
      @context
        .expects(:chdir)
        .with(@context.root)

      @context
        .expects(:dir_exist?)
        .with("#{@context.root}/#{@script_name}")
        .returns(false)

      Script::ScriptProject.cleanup(
        ctx: @context,
        script_name: @script_name,
        root_dir: @context.root
      )
    end

    def test_reads_language_from_config_file
      language = 'Rust'
      Script::Layers::Application::SupportedLanguages.expects(:all).returns(%(AssemblyScript Rust))
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with('.shopify-cli.yml')
        .returns({
          'extension_point_type' => @extension_point_type,
          'script_name' => @script_name,
          'language' => language,
        })

      script = ScriptProject.new(directory: 'testdir')
      assert_equal language, script.language
    end

    def test_fallsback_to_assemblyscript_if_config_doesnt_specify_language
      Script::Layers::Application::SupportedLanguages.expects(:all).returns(%(AssemblyScript Rust))
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with('.shopify-cli.yml')
        .returns({
          'extension_point_type' => @extension_point_type,
          'script_name' => @script_name,
        })

      script = ScriptProject.new(directory: 'testdir')
      assert_equal 'AssemblyScript', script.language
    end

    def test_unsupported_language_in_config_will_raise
      language = 'C++'
      Script::Layers::Application::SupportedLanguages.expects(:all).returns(%(AssemblyScript Rust))
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with('.shopify-cli.yml')
        .returns({
          'extension_point_type' => @extension_point_type,
          'script_name' => @script_name,
          'language' => language,
        })

      assert_raises(Script::Errors::InvalidLanguageError) do
        ScriptProject.new(directory: 'testdir')
      end
    end
  end
end
