require "open-uri"
require "zlib"
require "open3"
require "digest/sha2"

module Javy
  ROOT = __dir__
  BIN_FOLDER = File.join(ShopifyCLI.cache_dir, "javy", "bin")
  HASH_FOLDER = File.join(ROOT, "hashes")
  VERSION = File.read(File.join(ROOT, "version")).strip
  TARGET = File.join(BIN_FOLDER, "javy-#{VERSION}")

  class << self
    def install
      ShopifyCLI::Result
        .wrap { Installer.call(target: target, platform: platform, version: VERSION) }
        .call
    end

    def build(source:, dest: nil)
      optional_args = []
      optional_args += ["-o", dest] unless dest.nil?

      ShopifyCLI::Result
        .wrap { ensure_installed }
        .call
        .then { exec(source, *optional_args) }
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
      install.unwrap { |e| raise e } unless Installer.installed?(target: target)
      true
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

    def self.invalid_binary
      new("Invalid Javy binary downloaded.")
    end
  end

  Asset = Struct.new(:platform, :version, :owner, :repository, :basename, keyword_init: true) do
    def download(target:)
      FileUtils.mkdir_p(BIN_FOLDER)

      source_file = url.open
      validate_sha!(source_file)
      source_file.seek(0)

      Dir.chdir(File.dirname(target)) do
        File.open(File.basename(target), "wb") do |target_file|
          decompress(source_file, target_file)
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

    def validate_sha!(source)
      generated_hash = Digest::SHA256.hexdigest(source.read).strip
      expected_hash = File.read(File.join(HASH_FOLDER, "#{filename}.sha256")).strip
      raise InstallationError.invalid_binary unless generated_hash == expected_hash
    end
  end

  Platform = Struct.new(:ruby_platform) do
    def initialize(ruby_platform = RUBY_PLATFORM)
      super(ruby_platform)
    end

    def to_s
      format("%{cpu}-%{os}", cpu: cpu, os: os)
    end

    def os
      case ruby_platform
      when /linux/
        "linux"
      when /darwin/
        "macos"
      else
        "windows"
      end
    end

    def cpu
      case ruby_platform
      when /x64/, /x86_64/
        "x86_64"
      when /arm/
        "arm"
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
