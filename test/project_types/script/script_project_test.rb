# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  class ScriptProjectTest < MiniTest::Test
    def setup
      super
      @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
      @script_name = "name"
      @extension_point_type = "ep_type"
    end

    def test_initialize
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with(".shopify-cli.yml")
        .returns({
          "extension_point_type" => @extension_point_type,
          "script_name" => @script_name,
        })

      Script::Layers::Application::ExtensionPoints.expects(:supported_language?).returns(true)
      ScriptProject.new(directory: @context.root)

      assert_equal({
        "script_name" => @script_name,
        "extension_point_type" => @extension_point_type,
        "language" => "assemblyscript",
      }, ShopifyCli::Core::Monorail.metadata)
    end

    def test_initialize_with_deprecated_ep
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with(".shopify-cli.yml")
        .returns({
          "extension_point_type" => @extension_point_type,
          "script_name" => @script_name,
        })

      Script::Layers::Application::ExtensionPoints.stubs(:deprecated_types).returns([@extension_point_type])

      assert_raises Errors::DeprecatedEPError do
        ScriptProject.new(directory: @context.root)
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
      language = "Rust"
      Script::Layers::Application::ExtensionPoints.expects(:languages).returns(%(assemblyscript rust))
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with(".shopify-cli.yml")
        .returns({
          "extension_point_type" => @extension_point_type,
          "script_name" => @script_name,
          "language" => language,
        })

      script = ScriptProject.new(directory: @context.root)
      assert_equal language.downcase, script.language
    end

    def test_fallsback_to_assemblyscript_if_config_doesnt_specify_language
      Script::Layers::Application::ExtensionPoints.expects(:languages).returns(%(assemblyscript rust))
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with(".shopify-cli.yml")
        .returns({
          "extension_point_type" => @extension_point_type,
          "script_name" => @script_name,
        })

      script = ScriptProject.new(directory: @context.root)
      assert_equal "assemblyscript", script.language
    end

    def test_unsupported_language_in_config_will_raise
      language = "C++"
      Script::Layers::Application::ExtensionPoints.expects(:languages).returns(%(assemblyscript rust))
      ShopifyCli::Project
        .any_instance
        .expects(:load_yaml_file)
        .with(".shopify-cli.yml")
        .returns({
          "extension_point_type" => @extension_point_type,
          "script_name" => @script_name,
          "language" => language,
        })

      assert_raises(Script::Errors::InvalidLanguageError) do
        ScriptProject.new(directory: @context.root)
      end
    end

    describe "#configuration_ui_yaml" do
      let(:configuration_ui_file) { "ui-config.yml" }
      let(:language) { "assemblyscript" }

      before do
        @context.root = Dir.mktmpdir
        Dir.stubs(:pwd).returns(@context.root)
        Script::Layers::Application::ExtensionPoints.stubs(:deprecated_types).returns([])
        Script::Layers::Application::ExtensionPoints.stubs(:languages).returns(%(assemblyscript rust))
      end

      subject do
        Script::ScriptProject.current.configuration_ui_yaml
      end

      describe "when ui_configuration_file field exists in config" do
        before do
          Script::ScriptProject.write(
            @context,
            project_type: :script,
            organization_id: nil,
            extension_point_type: @extension_point_type,
            script_name: @script_name,
            language: language,
            configuration_ui_file: configuration_ui_file
          )
        end

        describe "when file exists" do
          describe "when YAML is valid" do
            let(:configuration_ui_yaml) { "---\nversion: 1" }

            it "returns the raw contents" do
              @context.write(configuration_ui_file, configuration_ui_yaml)
              assert_equal configuration_ui_yaml, subject
            end
          end

          describe "when YAML is invalid" do
            let(:configuration_ui_yaml) { "*" }

            it "raises InvalidConfigUiDefinitionError" do
              @context.write(configuration_ui_file, configuration_ui_yaml)
              assert_raises(Script::Errors::InvalidConfigUiDefinitionError) { subject }
            end
          end
        end

        describe "when file does not exist" do
          it "raises MissingSpecifiedConfigUiDefinitionError" do
            assert_raises(Script::Errors::MissingSpecifiedConfigUiDefinitionError) { subject }
          end
        end
      end

      describe "when ui_configuration_file field does not exist in config" do
        it "returns nil" do
          Script::ScriptProject.write(
            @context,
            project_type: :script,
            organization_id: nil,
            extension_point_type: @extension_point_type,
            script_name: @script_name,
            language: language,
          )
          assert_nil subject
        end
      end
    end
  end
end
