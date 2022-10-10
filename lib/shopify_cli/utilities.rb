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

    def self.deep_merge(first, second)
      merger = proc { |_key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      first.merge(second, &merger)
    end
  end
end
