require "json"

module ShopifyCLI
  class AppTypeDetector
    Error = Class.new(StandardError)
    TypeNotFoundError = Class.new(Error)

    def self.detect(project_directory:)
      return :node if node?(project_directory: project_directory)
      return :rails if rails?(project_directory: project_directory)
      return :php if php?(project_directory: project_directory)
      raise TypeNotFoundError, "Couldn't detect the project type in directory: #{project_directory}"
    end

    def self.node?(project_directory:)
      package_json_path = File.join(project_directory, "package.json")
      return false unless File.exist?(package_json_path)
      package_json = JSON.parse(File.read(package_json_path))
      !package_json.dig("scripts", "dev").nil?
    end

    def self.rails?(project_directory:)
      rails_binstub_path = File.join(project_directory, "bin/rails")
      File.exist?(rails_binstub_path)
    end

    def self.php?(project_directory:)
      bootstrap_app_path = File.join(project_directory, "bootstrap/app.php")
      File.exist?(bootstrap_app_path)
    end
  end
end
