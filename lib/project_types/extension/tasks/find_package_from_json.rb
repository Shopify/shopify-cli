# frozen_string_literal: true
require "json"

module Extension
  module Tasks
    class FindPackageFromJson < ShopifyCLI::Task
      include SmartProperties

      property! :context, accepts: ShopifyCLI::Context

      def self.call(package_name, **config)
        new(**config).call(package_name)
      end

      def call(package_name)
        ShopifyCLI::Result.success(resolve_package_json(package_name))
          .then { |file| File.read(file) }
          .then { |file| JSON.parse(file) }
          .then { |file| file.dig("version") }
          .then { |version| return Models::NpmPackage.new(name: package_name, version: version) }
          .unwrap do |error|
            context.debug(error)
            context.abort(context.message("errors.module_not_found", package_name))
          end
      end

      private

      def resolve_package_json(package_name)
        path = "path.join(require.resolve('#{package_name}'), '../package.json')"
        package_json, error, _ = CLI::Kit::System.capture3("node", "-p", path)
        return error unless !error.nil?
        package_json.chomp
      end
    end
  end
end
