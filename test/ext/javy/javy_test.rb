require "test_helper"
require_relative "../../../ext/javy/javy.rb"

class JavyTest < Minitest::Test
  include TestHelpers::FakeFS

  def setup
    super
    FileUtils.mkdir_p(::Javy::ROOT)
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
  end

  def test_build_runs_javy_command_on_unix
    stub_executable_download
    install(PlatformHelper.macos_config)

    source = "src/index.js"
    dest = "build/index.wasm"

    CLI::Kit::System.expects(:capture2e).with(Javy::TARGET, source, "-o", dest, anything)
    Javy.build(source: source, dest: dest)
  end

  def test_build_runs_javy_command_on_windows
    stub_executable_download
    install(PlatformHelper.windows_config)

    source = "src/index.js"
    dest = "build/index.wasm"

    CLI::Kit::System.expects(:capture2e).with(Javy::TARGET + ".exe", source, "-o", dest, anything)
    Javy.build(source: source, dest: dest)
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

  def stub_executable_download
    stub_executable_download_request("linux")
    stub_executable_download_request("macos")
    stub_executable_download_request("windows")
  end

  def stub_executable_download_request(os)
    stub_request(:get, "https://github.com/Shopify/javy/releases/download/v0.1.0/javy-x86_64-#{os}-v0.1.0.gz")
      .to_return(
      status: 200,
      headers: {
        "Content-Type" => "application/octet-stream",
        "Content-Disposition" => "attachment; filename=javy-x86_64-#{os}-v0.1.0.gz",
        "Content-Length" => dummy_archive.size,
      },
      body: dummy_archive
    )
  end

  def simulate_broken_asset_link
    stub_request(:get, "https://github.com/Shopify/javy/releases/download/v0.1.0/javy-x86_64-macos-v0.1.0.gz")
      .to_raise(OpenURI::HTTPError.new("404 Not Found", StringIO.new))
  end

  def dummy_archive
    @dummy_archive ||= "\u001F\x8B\b\u0000\x9C\xE1{a\u0000\u0003ST"\
      "\xD6O\xCA\xCC\xD3OJ,\xCE\xE0JM\xCE\xC8WP\xCFH"\
      "\xCD\xC9\xC9W(\xCF/\xCAIQ\a\u00007Q\xAC4\u001E"\
      "\u0000\u0000\u0000"
  end

  module PlatformHelper
    def self.linux_config
      ruby_config(os: "linux-gnu", cpu: "x86_64")
    end

    def self.macos_config
      ruby_config(os: "darwin20.3.0", cpu: "x86_64")
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
