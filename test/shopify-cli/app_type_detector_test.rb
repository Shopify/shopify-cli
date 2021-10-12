require "test_helper"
require "json"

module ShopifyCLI
  class AppTypeDetectorTest < MiniTest::Test
    include TestHelpers::TemporaryDirectory

    def test_when_type_cannot_be_detected
      # Given
      project_directory = @tmp_dir

      # When
      error = assert_raises(AppTypeDetector::TypeNotFoundError) do
        AppTypeDetector.detect(project_directory: project_directory)
      end

      # Then
      assert_equal(
        "Couldn't detect the project type in directory: #{project_directory}",
        error.message
      )
    end

    def test_when_type_is_node
      # Given
      project_directory = @tmp_dir
      package_json_path = File.join(project_directory, "package.json")
      package_json = {
        "scripts" => {
          "dev" => "nodemon ./server/index.js",
        },
      }
      File.write(package_json_path, package_json.to_json)

      # When/Then
      assert_equal :node, AppTypeDetector.detect(project_directory: project_directory)
    end
  end
end
