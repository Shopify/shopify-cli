module CLI
  def self.version
    version_file_path = File.expand_path("../../lib/shopify_cli/version.rb", __dir__)
    version_file_content = File.read(version_file_path)
    version_file_content.match(/VERSION\s+=\s+"(?<version>[0-9]+\.[0-9]+\.[0-9]+)"/)[:version].chomp
  end
end
