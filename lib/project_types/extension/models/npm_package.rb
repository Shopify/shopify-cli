require "semantic/semantic"

module Extension
  module Models
    class NpmPackage
      include SmartProperties
      include Comparable

      property :name
      property :version
      property :scripts, accepts: Hash
      property :dependencies, accepts: Hash
      property :dev_dependencies, accepts: Hash

      def initialize(**config)
        super(**config.select { |property_name, _| self.class.properties.key?(property_name) })
      end

      def self.parse(io)
        ShopifyCLI::Result.call { JSON.parse(io.read) }
          .then(&ShopifyCLI::TransformDataStructure.new(underscore_keys: true, symbolize_keys: true, shallow: true))
          .then { |specification| new(**specification) }
          .unwrap { |error| raise "Failed to parse NPM package specification: #{error}" }
      end

      def <=>(other)
        return nil unless name == other.name
        Semantic::Version.new(version) <=> Semantic::Version.new(other.version)
      end
    end
  end
end
