require "rbconfig"
require "open-uri"
require "zlib"
require "open3"

module ShopifyExtensions
  def self.install(**args)
    Install.call(**args)
  end

  class Install
    def self.call(platform: Platform.new, **args)
      new.call(platform: platform, **args)
    end

    def self.version
      File.read(File.expand_path("../version", __FILE__)).strip
    end

    def call(platform:, version: self.class.version, target:)
      target = platform.format_path(target.to_s)

      asset = Asset.new(
        platform: platform,
        version: version,
        owner: "Shopify",
        repository: "shopify-cli-extensions",
        basename: "shopify-extensions"
      )
      downloaded = asset.download(target: target)
      raise InstallationError.asset_not_found(platform: platform, version: version) unless downloaded

      raise InstallationError.installation_failed unless verify(target, version: version)
    end

    private

    def fetch_release_details_for(version:)
      JSON.parse(URI.parse(release_url_for(version: version)).open.read).yield_self(&Release)
    rescue OpenURI::HTTPError
      nil
    end

    def verify(target, version:)
      return false unless File.executable?(target)
      installed_server_version, exit_code = Open3.capture2(target, "version")
      return false unless exit_code == 0
      return false unless installed_server_version.strip == version.strip
      true
    end
  end

  class InstallationError < RuntimeError
    def self.installation_failed
      new("Failed to install shopify-extensions properly")
    end

    def self.asset_not_found(platform:, version:)
      new(format(
        "Unable to download shopify-extensions %{version} for %{os} (%{cpu})",
        version: version,
        os: platform.os,
        cpu: platform.cpu
      ))
    end
  end

  Asset = Struct.new(:platform, :version, :owner, :repository, :basename, keyword_init: true) do
    def download(target:)
      Dir.chdir(File.dirname(target)) do
        File.open(File.basename(target), "wb") do |target_file|
          decompress(url.open, target_file)
        end
        File.chmod(0755, target)
      end

      true
    rescue OpenURI::HTTPError
      false
    end

    def url
      URI.parse(format(
        "https://github.com/%{owner}/%{repository}/releases/download/%{version}/%{filename}",
        owner: owner,
        repository: repository,
        version: version,
        filename: filename
      ))
    end

    def filename
      format(
        "%{basename}-%{os}-%{cpu}.%{extension}",
        basename: basename,
        os: platform.os,
        cpu: platform.cpu,
        extension: platform.os == "windows" ? "exe.gz" : "gz"
      )
    end

    private

    def decompress(source, target)
      zlib = Zlib::GzipReader.new(source)
      target << zlib.read
    ensure
      zlib.close
    end
  end

  Platform = Struct.new(:ruby_config) do
    def initialize(ruby_config = RbConfig::CONFIG)
      super(ruby_config)
    end

    def format_path(path)
      case os
      when "windows"
        File.extname(path) != ".exe" ? path + ".exe" : path
      else
        path
      end
    end

    def to_s
      format("%{os}-%{cpu}", os: os, cpu: cpu)
    end

    def os
      case ruby_config.fetch("host_os")
      when /linux/
        "linux"
      when /darwin/
        "darwin"
      else
        "windows"
      end
    end

    def cpu
      case ruby_config.fetch("host_cpu")
      when /arm.*64/
        "arm64"
      when /64/
        "amd64"
      else
        "386"
      end
    end
  end
end
