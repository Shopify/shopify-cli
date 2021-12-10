require "test_helper"
require_relative "../../../ext/javy/javy.rb"

class JavyTest < Minitest::Test
  include TestHelpers::FakeFS

  DUMMY_ARCHIVE = "\u001F\x8B\b\u0000\x9C\xE1{a\u0000\u0003ST"\
  "\xD6O\xCA\xCC\xD3OJ,\xCE\xE0JM\xCE\xC8WP\xCFH"\
  "\xCD\xC9\xC9W(\xCF/\xCAIQ\a\u00007Q\xAC4\u001E"\
  "\u0000\u0000\u0000"
  DUMMY_ARCHIVE_SHA256 = Digest::SHA256.hexdigest(DUMMY_ARCHIVE)
  ASSET_FILENAME = "javy-x86_64-%s-v0.1.0.gz"

  def setup
    super
    FileUtils.mkdir_p(::Javy::BIN_FOLDER)
    FileUtils.mkdir_p(::Javy::HASH_FOLDER)
    File.write(File.join(::Javy::ROOT, "version"), "v0.1.0")
  end

  def test_install_existing_version_for_mac_os
    stub_executable_download

    assert_kind_of(ShopifyCLI::Result::Success, install(PlatformHelper.macos_config))

    assert File.file?(Javy::TARGET)
    assert File.executable?(Javy::TARGET)
  end

  def test_install_existing_version_for_windows
    stub_executable_download

    expected_target = Javy::TARGET + ".exe"
    assert_kind_of(ShopifyCLI::Result::Success, install(PlatformHelper.windows_config))

    assert File.file?(expected_target)
    assert File.executable?(expected_target)
  end

  def test_install_existing_version_for_linux
    stub_executable_download

    assert_kind_of(ShopifyCLI::Result::Success, install(PlatformHelper.linux_config))

    assert File.file?(Javy::TARGET)
    assert File.executable?(Javy::TARGET)
  end

  def test_install_raises_for_http_errors_during_asset_download
    simulate_broken_asset_link

    result = install(PlatformHelper.macos_config)
    assert_kind_of(ShopifyCLI::Result::Failure, result)
    assert_kind_of(Javy::InstallationError, result.error)
    assert_match("Unable to download javy", result.error.message)
    refute File.file?(Javy::TARGET)
  end

  def test_install_raises_when_binary_hash_is_unexpected
    stub_executable_download(executable_sha: "invalid")
    result = install(PlatformHelper.macos_config)
    assert_kind_of(ShopifyCLI::Result::Failure, result)
    assert_kind_of(Javy::InstallationError, result.error)
    assert_match("Invalid Javy binary downloaded", result.error.message)
    refute File.file?(Javy::TARGET)
  end

  def test_install_strips_whitespace_when_comparing_shas
    stub_executable_download(executable_sha: "#{DUMMY_ARCHIVE_SHA256} \n")
    assert_kind_of(ShopifyCLI::Result::Success, install(PlatformHelper.macos_config))

    assert File.file?(Javy::TARGET)
    assert File.executable?(Javy::TARGET)
  end

  def test_build_runs_javy_command_on_unix
    stub_executable_download
    install(PlatformHelper.macos_config)
    run_build_and_expect_execution
  end

  def test_build_runs_javy_command_on_windows
    stub_executable_download
    install(PlatformHelper.windows_config)
    run_build_and_expect_execution(target: Javy::TARGET + ".exe")
  end

  def test_build_accepts_optional_dest_argument
    stub_executable_download
    install(PlatformHelper.macos_config)
    run_build_and_expect_execution(dest: nil)
  end

  def test_build_installs_javy_by_default
    stub_executable_download

    refute File.file?(Javy::TARGET)
    refute File.executable?(Javy::TARGET)

    run_build_and_expect_execution

    assert File.file?(Javy::TARGET)
    assert File.executable?(Javy::TARGET)
  end

  def test_build_deletes_outdated_javy_installations_and_installs_new_one
    outdated_javy_target = File.join(Javy::BIN_FOLDER, "javy-0.0.0")
    File.write(outdated_javy_target, "foo")

    stub_executable_download
    run_build_and_expect_execution

    refute File.file?(outdated_javy_target)
    assert File.file?(Javy::TARGET)
    assert File.executable?(Javy::TARGET)
  end

  def test_build_does_not_reinstall_an_ok_javy_version
    File.write(Javy::TARGET, "")
    File.chmod(0755, Javy::TARGET)
    run_build_and_expect_execution
  end

  class PlatformTest < MiniTest::Test
    def test_recognizes_linux
      platform = Javy::Platform.new(PlatformHelper.linux_config)
      assert_equal "x86_64-linux", platform.to_s
      assert_equal "javy", platform.format_executable_path("javy")
    end

    def test_recognizes_mac_os
      platform = Javy::Platform.new(PlatformHelper.macos_config)
      assert_equal "x86_64-macos", platform.to_s
      assert_equal "javy", platform.format_executable_path("javy")
    end

    def test_recognizes_mac_os_arm64
      platform = Javy::Platform.new(PlatformHelper.macos_arm_config)
      assert_equal "arm-macos", platform.to_s
      assert_equal "javy", platform.format_executable_path("javy")
    end

    def test_recognizes_windows
      platform = Javy::Platform.new(PlatformHelper.windows_config)
      assert_equal "x86_64-windows", platform.to_s
      assert_equal "javy.exe", platform.format_executable_path("javy")
    end

    def test_unsupported_on_32_bit_machines
      assert_raises(Javy::InstallationError) do
        Javy::Platform.new(PlatformHelper.windows_32_bit_config).to_s
      end
    end
  end

  private

  def install(platform_config)
    stubbed_platform = Javy::Platform.new(platform_config)
    Javy::Platform.stubs(:new).returns(stubbed_platform)
    Javy.install
  end

  def run_build_and_expect_execution(source: "src/index.js", dest: "build/index.wasm", target: Javy::TARGET)
    optional_args = dest.nil? ? [] : ["-o", dest]

    CLI::Kit::System.expects(:capture2e).with(target, source, *optional_args, anything)
    Javy.build(source: source, dest: dest)
  end

  def stub_executable_download(executable_sha: DUMMY_ARCHIVE_SHA256)
    stub_executable_download_request("linux", executable_sha)
    stub_executable_download_request("macos", executable_sha)
    stub_executable_download_request("windows", executable_sha)
  end

  def stub_executable_download_request(os, executable_sha)
    asset_filename = ASSET_FILENAME % os
    File.write(File.join(::Javy::HASH_FOLDER, "#{asset_filename}.sha256"), executable_sha)
    stub_request(:get, "https://github.com/Shopify/javy/releases/download/v0.1.0/#{asset_filename}")
      .to_return(
      status: 200,
      headers: {
        "Content-Type" => "application/octet-stream",
        "Content-Disposition" => "attachment; filename=javy-#{asset_filename}",
        "Content-Length" => DUMMY_ARCHIVE.size,
      },
      body: DUMMY_ARCHIVE
    )
  end

  def simulate_broken_asset_link
    stub_request(:get, "https://github.com/Shopify/javy/releases/download/v0.1.0/#{ASSET_FILENAME % "macos"}")
      .to_raise(OpenURI::HTTPError.new("404 Not Found", StringIO.new))
  end

  module PlatformHelper
    def self.linux_config
      ruby_config(os: "linux-gnu", cpu: "x86_64")
    end

    def self.macos_config
      ruby_config(os: "darwin20.3.0", cpu: "x86_64")
    end

    def self.macos_arm_config
      ruby_config(os: "darwin20.3.0", cpu: "arm")
    end

    def self.windows_config
      ruby_config(os: "mingw32", cpu: "x64")
    end

    def self.windows_32_bit_config
      ruby_config(os: "mingw32", cpu: "i686")
    end

    def self.ruby_config(os:, cpu:)
      {
        "host_os" => os,
        "host_cpu" => cpu,
      }
    end
  end
end
