module ShopifyCLI
  module Utilities
    def self.version_dropping_pre_and_build(version)
      Semantic::Version.new("#{version.major}.#{version.minor}.#{version.patch}")
    end
  end
end
