# typed: ignore
require "semantic/semantic"

module Extension
  module Models
    NpmPackage = Struct.new(:name, :version, keyword_init: true) do
      include Comparable

      def <=>(other)
        return nil unless name == other.name
        Semantic::Version.new(version) <=> Semantic::Version.new(other.version)
      end
    end
  end
end
