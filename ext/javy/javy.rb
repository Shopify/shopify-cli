require "rbconfig"
require "open-uri"
require "zlib"
require "open3"

class Javy
  TARGET = File.join(__dir__, "javy")

  def self.install(**args)
    new.install(**args)
  end

  def self.build(**args)
    new.build(**args)
  end

  def install(**args)
    Install.call(target: TARGET, platform: platform, **args)
  end

  def build(source:, dest:)
    exec("#{source} -o #{dest}")
  end

  private

  def exec(*args, **kwargs)
    system(TARGET, *args, **kwargs)
  end

  def platform
    @platform ||= Platform.new
  end

  class Install
    def self.call(target:, platform:, **args)
      new.call(target: target, platform: platform, **args)
    end

    def self.version
      File.read(File.expand_path("../version", __FILE__)).strip
    end

    def call(target:, platform:, version: self.class.version)
      target = platform.format_executable_path(target.to_s)

      asset = Asset.new(
        platform: platform,
        version: version,
        owner: "Shopify",
        repository: "javy",
        basename: "javy"
      )

      downloaded = asset.download(target: target)
      raise InstallationError.asset_not_found(platform: platform, version: version, url: asset.url) unless downloaded

      raise InstallationError.installation_failed unless verify_download(target)
    end

    private

    def fetch_release_details_for(version:)
      JSON.parse(URI.parse(release_url_for(version: version)).open.read).yield_self(&Release)
    rescue OpenURI::HTTPError
      nil
    end

    def verify_download(target)
      File.executable?(target)
    end
  end

  class InstallationError < RuntimeError
    def self.installation_failed
      new("Failed to install javy properly")
    end

    def self.cpu_unsupported
      new("Javy is not supported on this CPU")
    end

    def self.asset_not_found(platform:, version:, url:)
      new(format(
        "Unable to download javy %{version} for %{os} (%{cpu}) at %{url}",
        version: version,
        os: platform.os,
        cpu: platform.cpu,
        url: url
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
        "%{basename}-%{cpu}-%{os}-%{version}.gz",
        basename: basename,
        cpu: platform.cpu,
        os: platform.os,
        version: version
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

    def to_s
      format("%{cpu}-%{os}", cpu: cpu, os: os)
    end

    def os
      case ruby_config.fetch("host_os")
      when /linux/
        "linux"
      when /darwin/
        "macos"
      else
        "windows"
      end
    end

    def cpu
      host_cpu = ruby_config.fetch("host_cpu")
      case ruby_config.fetch("host_cpu")
      when "x64", "x86_64"
        "x86_64"
      else
        raise InstallationError.cpu_unsupported
      end
    end

    def format_executable_path(path)
      case os
      when "windows"
        File.extname(path) != ".exe" ? path + ".exe" : path
      else
        path
      end
    end
  end
end
