module Extension
  module Models
    NpmPackage = Struct.new(:name, :version, keyword_init: true) do
      include Comparable

      def <=>(other)
        return nil unless name == other.name
        Gem::Version.new(version) <=> Gem::Version.new(other.version)
      end
    end
  end
end
