module ShopifyCLI
  module Utilities
    def self.version_dropping_pre_and_build(version)
      Semantic::Version.new("#{version.major}.#{version.minor}.#{version.patch}")
    end

    def self.directory(pattern, curr)
      loop do
        return nil if curr == "/" || /^[A-Z]:\/$/.match?(curr)
        file = File.join(curr, pattern)
        return curr if File.exist?(file)
        curr = File.dirname(curr)
      end
    end
  end
end
