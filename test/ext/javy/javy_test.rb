require "test_helper"
require_relative "../../../ext/javy/javy.rb"

class JavyTest < Minitest::Test
  def test_installation_of_existing_version_for_mac_os
    stub_executable_download

    target = File.join(Dir.mktmpdir, "javy")

    Javy.install(
      platform: Javy::Platform.new({
        "host_os" => "darwin20.3.0",
        "host_cpu" => "x86_64",
      }),
      version: "v0.1.0",
      target: target
    )

    assert File.file?(target)
    assert File.executable?(target)
    assert_match(/v0.1.0/, %x(#{target}))
  end

  def test_installation_of_existing_version_for_windows
    stub_executable_download

    target = File.join(Dir.mktmpdir, "javy.exe")

    Javy.install(
      platform: Javy::Platform.new({
        "host_os" => "mingw32",
        "host_cpu" => "x64",
      }),
      version: "v0.1.0",
      target: target
    )

    assert File.file?(target)
    assert File.executable?(target)
  end

  def test_installing_on_windows_adds_exe_extension
    stub_executable_download

    target = File.join(Dir.mktmpdir, "javy")
    expected_target = target + ".exe"

    Javy.install(
      platform: Javy::Platform.new({
        "host_os" => "mingw32",
        "host_cpu" => "x64",
      }),
      version: "v0.1.0",
      target: target
    )

    assert File.file?(expected_target)
    assert File.executable?(expected_target)
  end

  def test_handle_http_errors_during_asset_download
    simulate_broken_asset_link

    target = File.join(Dir.mktmpdir, "javy")

    assert_raises(Javy::InstallationError) do
      Javy.install(
        platform: Javy::Platform.new({
          "host_os" => "darwin20.3.0",
          "host_cpu" => "x86_64",
        }),
        version: "v0.1.0",
        target: target
      )
    end
  end

  def test_incorrect_binary
    stub_executable_download

    target = File.join(Dir.mktmpdir, "javy.exe")
    File.expects(:executable?).with(target).returns(false)

    error = assert_raises(Javy::InstallationError) do
      Javy.install(
        platform: Javy::Platform.new({
          "host_os" => "mingw32",
          "host_cpu" => "x64",
        }),
        version: "v0.1.0",
        target: target
      )
    end

    assert_equal "Failed to install javy properly", error.message
  end

  class PlatformTest < MiniTest::Test
    def test_recognizes_linux
      linux_vm = ruby_config(os: "linux-gnu", cpu: "x86_64")
      assert_equal "x86_64-linux", Javy::Platform.new(linux_vm).to_s
    end

    def test_recognizes_mac_os
      intel_mac_vm = ruby_config(os: "darwin20.3.0", cpu: "x86_64")
      assert_equal "x86_64-macos", Javy::Platform.new(intel_mac_vm).to_s
    end

    def test_recognizes_windows
      windows_vm_64_bit = ruby_config(os: "mingw32", cpu: "x64")
      assert_equal "x86_64-windows", Javy::Platform.new(windows_vm_64_bit).to_s
    end

    def test_unsupported_on_32_bit_machines
      windows_vm_32_bit = ruby_config(os: "mingw32", cpu: "i686")
      assert_raises(Javy::InstallationError) do
        Javy::Platform.new(windows_vm_32_bit).to_s
      end
    end

    private

    def ruby_config(os:, cpu:)
      {
        "host_os" => os,
        "host_cpu" => cpu,
      }
    end
  end

  def stub_executable_download
    dummy_archive = load_dummy_archive

    stub_request(:get, "https://github.com/Shopify/javy/releases/download/v0.1.0/javy-x86_64-windows-v0.1.0.gz")
      .to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/octet-stream",
          "Content-Disposition" => "attachment; filename=javy-x86_64-windows-v0.1.0.gz",
          "Content-Length" => dummy_archive.size,
        },
        body: dummy_archive
      )

    stub_request(:get, "https://github.com/Shopify/javy/releases/download/v0.1.0/javy-x86_64-macos-v0.1.0.gz")
      .to_return(
        status: 200,
        headers: {
          "Content-Type" => "application/octet-stream",
          "Content-Disposition" => "attachment; filename=javy-x86_64-macos-v0.1.0.gz",
          "Content-Length" => dummy_archive.size,
        },
        body: dummy_archive
      )
  end

  def simulate_broken_asset_link
    stub_request(:get, "https://github.com/Shopify/javy/releases/download/v0.1.0/javy-x86_64-macos-v0.1.0.gz")
      .to_raise(OpenURI::HTTPError.new("404 Not Found", StringIO.new))
  end

  def load_dummy_archive
    path = File.expand_path("../../../fixtures/shopify-extensions.gz", __FILE__)
    raise "Dummy archive not found: #{path}" unless File.file?(path)
    File.read(path)
  end
end
