# typed: ignore
require "test_helper"
require_relative "../../../ext/shopify-extensions/shopify_extensions.rb"

module ShopifyExtensions
  class ShopfyExtensionsTest < Minitest::Test
    def test_installation_of_existing_version_for_mac_os
      stub_executable_download

      target = File.join(Dir.mktmpdir, "shopify-extensions")

      Install.call(
        platform: Platform.new({
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

      target = File.join(Dir.mktmpdir, "shopify-extensions.exe")

      Install.call(
        platform: Platform.new({
          "host_os" => "mingw32",
          "host_cpu" => "x64",
        }),
        version: "v0.1.0",
        target: target
      )

      assert File.file?(target)
      assert File.executable?(target)
    end

    def test_handle_http_errors_during_asset_download
      simulate_broken_asset_link

      target = File.join(Dir.mktmpdir, "shopify-extensions")

      assert_raises(InstallationError) do
        Install.call(
          platform: Platform.new({
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

      target = File.join(Dir.mktmpdir, "shopify-extensions.exe")
      File.expects(:executable?).with(target).returns(false)

      error = assert_raises(InstallationError) do
        Install.call(
          platform: Platform.new({
            "host_os" => "mingw32",
            "host_cpu" => "x64",
          }),
          version: "v0.1.0",
          target: target
        )
      end

      assert_equal "Failed to install shopify-extensions properly", error.message
    end

    class PlatformTest < MiniTest::Test
      def test_recognizes_linux
        linux_vm = ruby_config(os: "linux-gnu", cpu: "x86_64")
        assert_equal "linux-amd64", Platform.new(linux_vm).to_s
      end

      def test_recognizes_mac_os
        intel_mac = ruby_config(os: "darwin20.3.0", cpu: "x86_64")
        m1_mac = ruby_config(os: "darwin20.3.0", cpu: "arm64")

        assert_equal "darwin-amd64", Platform.new(intel_mac).to_s
        assert_equal "darwin-arm64", Platform.new(m1_mac).to_s
      end

      def test_recognizes_windows
        windows_vm_64_bit = ruby_config(os: "mingw32", cpu: "x64")
        windows_vm_32_bit = ruby_config(os: "mingw32", cpu: "i686")
        assert_equal "windows-amd64", Platform.new(windows_vm_64_bit).to_s
        assert_equal "windows-386", Platform.new(windows_vm_32_bit).to_s
      end

      def test_adds_exe_extension_to_binaries_on_windows
        windows_vm_64_bit = ruby_config(os: "mingw32", cpu: "x64")
        assert_equal "some/command.exe", Platform.new(windows_vm_64_bit).format_path("some/command")
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

      stub_request(:get, "https://github.com/Shopify/shopify-cli-extensions/releases/download/v0.1.0/shopify-extensions-windows-amd64.exe.gz")
        .to_return(
          status: 200,
          headers: {
            "Content-Type" => "application/octet-stream",
            "Content-Disposition" => "attachment; filename=shopify-extensions-windows-amd64.exe.gz",
            "Content-Length" => dummy_archive.size,
          },
          body: dummy_archive
        )

      stub_request(:get, "https://github.com/Shopify/shopify-cli-extensions/releases/download/v0.1.0/shopify-extensions-darwin-amd64.gz")
        .to_return(
          status: 200,
          headers: {
            "Content-Type" => "application/octet-stream",
            "Content-Disposition" => "attachment; filename=shopify-extensions-darwin-amd64.gz",
            "Content-Length" => dummy_archive.size,
          },
          body: dummy_archive
        )
    end

    def simulate_broken_asset_link
      stub_request(:get, "https://github.com/Shopify/shopify-cli-extensions/releases/download/v0.1.0/shopify-extensions-darwin-amd64.gz")
        .to_raise(OpenURI::HTTPError.new("404 Not Found", StringIO.new))
    end

    def load_dummy_archive
      path = File.expand_path("../../../fixtures/shopify-extensions.gz", __FILE__)
      raise "Dummy archive not found: #{path}" unless File.file?(path)
      File.read(path)
    end
  end
end
