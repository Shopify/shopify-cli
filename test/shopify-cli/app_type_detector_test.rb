require "test_helper"
require "json"
require "fileutils"
require "yaml"

module ShopifyCLI
  class AppTypeDetectorTest < MiniTest::Test
    include TestHelpers::TemporaryDirectory

    def test_when_the_shopify_yml_file_doesnt_exist
      # Given
      project_directory = @tmp_dir

      # When/Then
      assert_raises(AppTypeDetector::MissingShopifyCLIYamlError) do
        AppTypeDetector.detect(project_directory: project_directory)
      end
    end

    def test_when_type_is_invalid
      # Given
      project_directory = @tmp_dir
      write_shopify_yml("invalid")

      # When/Then
      assert_raises(AppTypeDetector::InvalidTypeError) do
        AppTypeDetector.detect(project_directory: project_directory)
      end
    end

    def test_when_type_doesnt_exist
      # Given
      project_directory = @tmp_dir
      write_shopify_yml(nil)

      # When/Then
      assert_raises(AppTypeDetector::TypeNotFoundError) do
        AppTypeDetector.detect(project_directory: project_directory)
      end
    end

    def test_when_type_is_node
      # Given
      project_directory = @tmp_dir
      write_shopify_yml("node")

      # When/Then
      assert_equal :node, AppTypeDetector.detect(project_directory: project_directory)
    end

    def test_when_type_is_rails
      # Given
      project_directory = @tmp_dir
      write_shopify_yml("rails")

      # When/Then
      assert_equal :rails, AppTypeDetector.detect(project_directory: project_directory)
    end

    def test_when_type_is_php
      # Given
      project_directory = @tmp_dir
      write_shopify_yml("php")

      # When/Then
      assert_equal :php, AppTypeDetector.detect(project_directory: project_directory)
    end

    private

    def write_shopify_yml(project_type)
      shopify_cli_yml_path = File.join(@tmp_dir, Constants::Files::SHOPIFY_CLI_YML)
      shopify_cli_yml = { project_type: project_type }
      File.write(shopify_cli_yml_path, shopify_cli_yml.to_yaml)
    end
  end
end
