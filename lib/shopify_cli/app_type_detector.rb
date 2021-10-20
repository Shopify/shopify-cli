require "json"

module ShopifyCLI
  class AppTypeDetector
    Error = Class.new(StandardError)
    MissingShopifyCLIYamlError = Class.new(Error)
    TypeNotFoundError = Class.new(Error)
    class InvalidTypeError < Error
      attr_reader :project_type
      def initialize(message, project_type:)
        @project_type = project_type
        super(message)
      end
    end

    def self.detect(project_directory:)
      require "yaml" # takes 20ms, so deferred as late as possible.

      shopify_cli_yml_path = File.join(project_directory, Constants::Files::SHOPIFY_CLI_YML)
      unless File.exist?(shopify_cli_yml_path)
        raise MissingShopifyCLIYamlError,
          "#{Constants::Files::SHOPIFY_CLI_YML} was not found in directory #{project_directory}"
      end
      shopify_cli = YAML.load_file(shopify_cli_yml_path)
      case shopify_cli["project_type"]&.to_sym
      when :node, :rails, :php
        shopify_cli["project_type"].to_sym
      when nil
        raise TypeNotFoundError, "Couldn't detect the project type in directory: #{project_directory}"
      else
        raise InvalidTypeError.new("The project found '' is not supported",
          project_type: shopify_cli["project_type"])
      end
    end
  end
end
