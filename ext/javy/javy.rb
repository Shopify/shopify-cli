require "rbconfig"
require "open-uri"
require "zlib"
require "open3"

module Javy
  ROOT = __dir__
  BIN_FOLDER = File.join(ROOT, "bin")
  VERSION = File.read(File.join(ROOT, "version")).strip
  TARGET = File.join(BIN_FOLDER, "javy-#{VERSION}")

  class << self
    def install
      ShopifyCLI::Result
        .wrap { Installer.call(target: target, platform: platform, version: VERSION) }
        .call
    end

    def build(source:, dest: nil)
      ensure_installed

      optional_args = []
      optional_args += ["-o", dest] unless dest.nil?

      ShopifyCLI::Result
        .wrap { exec(source, *optional_args) }
        .call
    end

    private

    def exec(*args, **kwargs)
      out_and_err, stat = CLI::Kit::System.capture2e(target, *args, **kwargs)
      raise ExecutionError, out_and_err unless stat.success?
      true
    end

    def platform
      Platform.new
    end

    def target
      platform.format_executable_path(TARGET)
    end

    def ensure_installed
      delete_outdated_installations
      install unless Installer.installed?(target: target)
    end
  
    def delete_outdated_installations
      installed_binaries
        .reject { |v| v == target }
        .each { |file| File.delete(file) }
    end
  
    def installed_binaries
      Dir[File.join(BIN_FOLDER, "javy-*")]
    end

    module Installer
      def self.call(target:, platform:, version:)
        asset = Asset.new(
          platform: platform,
          version: version,
          owner: "Shopify",
          repository: "javy",
          basename: "javy"
        )

        downloaded = asset.download(target: target)
        raise InstallationError.asset_not_found(platform: platform, version: version, url: asset.url) unless downloaded

        true
      end

      def self.installed?(target:)
        File.executable?(target)
      end
    end
  end

  class Error < RuntimeError; end
  class ExecutionError < Error; end

  class InstallationError < Error
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
