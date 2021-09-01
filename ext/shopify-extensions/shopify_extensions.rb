require "rbconfig"
require "open-uri"
require "json"
require "zlib"
require "rubygems"
require "rubygems/package"
require "open3"

module ShopifyExtensions
  def self.install(**args)
    Install.call(**args)
  end

  class Install
    def self.call(platform: Platform.new, **args)
      new.call(platform: platform, **args)
    end

    def call(platform:, version:, target:)
      target = platform.format_path(target)

      release = fetch_release_details_for(version: version)
      raise InstallationError.version_not_found(version) unless release

      downloaded = release.download(platform: platform, target: target)
      raise InstallationError.asset_not_found(platform: platform, version: version) unless downloaded

      raise InstallationError.installation_failed unless verify(target, version: version)
    end

    private

    def fetch_release_details_for(version:)
      JSON.parse(URI.parse(release_url_for(version: version)).open.read).yield_self(&Release)
    rescue OpenURI::HTTPError
      nil
    end

    def release_url_for(version:)
      format(
        "https://api.github.com/repos/%{owner}/%{repo}/releases/tags/%{version}",
        owner: "Shopify",
        repo: "shopify-cli-extensions",
        version: version
      )
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

    def self.incorrect_version
      new("Failed to install the correct version of shopify-extensions")
    end

    def self.version_not_found(version)
      new(format("Version %{version} of shopify-extensions does not exist", version: version))
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

  Release = Struct.new(:version, :assets, keyword_init: true) do
    def self.to_proc
      ->(release_data) do
        new(
          version: release_data.fetch("tag_name"),
          assets: release_data.fetch("assets").map(&Asset)
        )
      end
    end

    def download(platform:, target:)
      !!assets
        .filter(&:binary?)
        .find { |asset| asset.os == platform.os && asset.cpu == platform.cpu }
        .tap { |asset| return false unless asset }
        .download(target: target)
    end
  end

  Asset = Struct.new(:filename, :url, keyword_init: true) do
    def self.to_proc
      ->(asset_data) do
        new(
          filename: asset_data.fetch("name"),
          url: asset_data.fetch("browser_download_url")
        )
      end
    end

    def download(target:)
      Dir.chdir(File.dirname(target)) do
        File.open(File.basename(target), "wb") do |target_file|
          decompress(URI.parse(url).open, target_file)
        end
        File.chmod(0755, target)
      end

      true
    rescue OpenURI::HTTPError
      false
    end

    def binary?
      !!/\.gz$/.match(filename)
    end

    def checksum?
      !!/\.md5$/.match(filename)
    end

    def os
      name.split("-")[-2]
    end

    def cpu
      name.split("-")[-1]
    end

    private

    def decompress(source, target)
      zlib = Zlib::GzipReader.new(source)
      target << zlib.read
    ensure
      zlib.close
    end

    def name
      if binary?
        File.basename(File.basename(filename, ".gz"), ".exe")
      elsif checksum?
        File.basename(File.basename(filename, ".md5"), ".exe")
      else
        raise NotImplementedError, "Unknown file type"
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
end
