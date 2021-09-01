require "test_helper"
require_relative "../../../ext/shopify-extensions/shopify_extensions.rb"

module ShopifyExtensions
  class ShopfyExtensionsTest < Minitest::Test
    def test_installation_of_existing_version_for_mac_os
      stub_release_request
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
      stub_release_request
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

    def test_installation_of_non_existing_version
      simulate_non_existing_release

      target = File.join(Dir.mktmpdir, "shopify-extensions")

      error = assert_raises(InstallationError) do
        Install.call(
          platform: Platform.new({
            "host_os" => "darwin20.3.0",
            "host_cpu" => "x86_64",
          }),
          version: "v0.0.0",
          target: target
        )
      end

      assert_equal "Version v0.0.0 of shopify-extensions does not exist", error.message
      refute File.file?(target)
    end

    def test_installation_of_version_that_has_no_assets
      simulate_release_without_assets

      target = File.join(Dir.mktmpdir, "shopify-extensions")

      error = assert_raises(InstallationError) do
        Install.call(
          platform: Platform.new({
            "host_os" => "darwin20.3.0",
            "host_cpu" => "x86_64",
          }),
          version: "v0.1.0",
          target: target
        )
      end

      assert_equal "Unable to download shopify-extensions v0.1.0 for darwin (amd64)", error.message
      refute File.file?(target)
    end

    def test_handle_http_errors_during_asset_download
      stub_release_request
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
      stub_release_request
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

      def test_recognices_mac_os
        intel_mac = ruby_config(os: "darwin20.3.0", cpu: "x86_64")
        m1_mac = ruby_config(os: "darwin20.3.0", cpu: "arm64")

        assert_equal "darwin-amd64", Platform.new(intel_mac).to_s
        assert_equal "darwin-arm64", Platform.new(m1_mac).to_s
      end

      def test_recognices_windows
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

    class AssetTest < MiniTest::Test
      def test_initialization_for_mac_os
        asset = Asset.new(
          filename: "shopify-extensions-v0.1.0-darwin-amd64.gz",
          url: "https://github.com/Shopify/shopify-cli-extensions/releases/download/v0.1.0/shopify-extensions-darwin-amd64.gz"
        )

        assert_equal "darwin", asset.os
        assert_equal "amd64", asset.cpu
      end

      def test_initialization_for_windows
        asset = Asset.new(
          filename: "shopify-extensions-v0.1.0-windows-amd64.exe.gz",
          url: "https://github.com/Shopify/shopify-cli-extensions/releases/download/v0.1.0/shopify-extensions-windows-amd64.exe.gz"
        )

        assert_equal "windows", asset.os
        assert_equal "amd64", asset.cpu
      end
    end

    def stub_release_request
      stub_request(:get, "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/tags/v0.1.0")
        .to_return(status: 200, body: <<~JSON)
          {
            "url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/49531769",
            "assets_url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/49531769/assets",
            "upload_url": "https://uploads.github.com/repos/Shopify/shopify-cli-extensions/releases/49531769/assets{?name,label}",
            "html_url": "https://github.com/Shopify/shopify-cli-extensions/releases/tag/v0.1.0",
            "id": 49531769,
            "author": {
              "login": "t6d",
              "id": 77060,
              "node_id": "MDQ6VXNlcjc3MDYw",
              "avatar_url": "https://avatars.githubusercontent.com/u/77060?v=4",
              "gravatar_id": "",
              "url": "https://api.github.com/users/t6d",
              "html_url": "https://github.com/t6d",
              "followers_url": "https://api.github.com/users/t6d/followers",
              "following_url": "https://api.github.com/users/t6d/following{/other_user}",
              "gists_url": "https://api.github.com/users/t6d/gists{/gist_id}",
              "starred_url": "https://api.github.com/users/t6d/starred{/owner}{/repo}",
              "subscriptions_url": "https://api.github.com/users/t6d/subscriptions",
              "organizations_url": "https://api.github.com/users/t6d/orgs",
              "repos_url": "https://api.github.com/users/t6d/repos",
              "events_url": "https://api.github.com/users/t6d/events{/privacy}",
              "received_events_url": "https://api.github.com/users/t6d/received_events",
              "type": "User",
              "site_admin": false
            },
            "node_id": "RE_kwDOF4czm84C88t5",
            "tag_name": "v0.1.0",
            "target_commitish": "main",
            "name": "v0.1.0",
            "draft": false,
            "prerelease": true,
            "created_at": "2021-09-14T13:43:17Z",
            "published_at": "2021-09-14T14:04:11Z",
            "assets": [
              {
                "url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/assets/44743653",
                "id": 44743653,
                "node_id": "RA_kwDOF4czm84Cqrvl",
                "name": "shopify-extensions-darwin-amd64.gz",
                "label": "",
                "uploader": {
                  "login": "github-actions[bot]",
                  "id": 41898282,
                  "node_id": "MDM6Qm90NDE4OTgyODI=",
                  "avatar_url": "https://avatars.githubusercontent.com/in/15368?v=4",
                  "gravatar_id": "",
                  "url": "https://api.github.com/users/github-actions%5Bbot%5D",
                  "html_url": "https://github.com/apps/github-actions",
                  "followers_url": "https://api.github.com/users/github-actions%5Bbot%5D/followers",
                  "following_url": "https://api.github.com/users/github-actions%5Bbot%5D/following{/other_user}",
                  "gists_url": "https://api.github.com/users/github-actions%5Bbot%5D/gists{/gist_id}",
                  "starred_url": "https://api.github.com/users/github-actions%5Bbot%5D/starred{/owner}{/repo}",
                  "subscriptions_url": "https://api.github.com/users/github-actions%5Bbot%5D/subscriptions",
                  "organizations_url": "https://api.github.com/users/github-actions%5Bbot%5D/orgs",
                  "repos_url": "https://api.github.com/users/github-actions%5Bbot%5D/repos",
                  "events_url": "https://api.github.com/users/github-actions%5Bbot%5D/events{/privacy}",
                  "received_events_url": "https://api.github.com/users/github-actions%5Bbot%5D/received_events",
                  "type": "Bot",
                  "site_admin": false
                },
                "content_type": "application/gzip",
                "state": "uploaded",
                "size": 5073690,
                "download_count": 2,
                "created_at": "2021-09-14T14:04:52Z",
                "updated_at": "2021-09-14T14:04:53Z",
                "browser_download_url": "https://github.com/Shopify/shopify-cli-extensions/releases/download/v0.1.0/shopify-extensions-darwin-amd64.gz"
              },
              {
                "url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/assets/44743655",
                "id": 44743655,
                "node_id": "RA_kwDOF4czm84Cqrvn",
                "name": "shopify-extensions-darwin-amd64.md5",
                "label": "",
                "uploader": {
                  "login": "github-actions[bot]",
                  "id": 41898282,
                  "node_id": "MDM6Qm90NDE4OTgyODI=",
                  "avatar_url": "https://avatars.githubusercontent.com/in/15368?v=4",
                  "gravatar_id": "",
                  "url": "https://api.github.com/users/github-actions%5Bbot%5D",
                  "html_url": "https://github.com/apps/github-actions",
                  "followers_url": "https://api.github.com/users/github-actions%5Bbot%5D/followers",
                  "following_url": "https://api.github.com/users/github-actions%5Bbot%5D/following{/other_user}",
                  "gists_url": "https://api.github.com/users/github-actions%5Bbot%5D/gists{/gist_id}",
                  "starred_url": "https://api.github.com/users/github-actions%5Bbot%5D/starred{/owner}{/repo}",
                  "subscriptions_url": "https://api.github.com/users/github-actions%5Bbot%5D/subscriptions",
                  "organizations_url": "https://api.github.com/users/github-actions%5Bbot%5D/orgs",
                  "repos_url": "https://api.github.com/users/github-actions%5Bbot%5D/repos",
                  "events_url": "https://api.github.com/users/github-actions%5Bbot%5D/events{/privacy}",
                  "received_events_url": "https://api.github.com/users/github-actions%5Bbot%5D/received_events",
                  "type": "Bot",
                  "site_admin": false
                },
                "content_type": "application/octet-stream",
                "state": "uploaded",
                "size": 53,
                "download_count": 0,
                "created_at": "2021-09-14T14:04:53Z",
                "updated_at": "2021-09-14T14:04:53Z",
                "browser_download_url": "https://github.com/Shopify/shopify-cli-extensions/releases/download/v0.1.0/shopify-extensions-darwin-amd64.md5"
              },
              {
                "url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/assets/44743627",
                "id": 44743627,
                "node_id": "RA_kwDOF4czm84CqrvL",
                "name": "shopify-extensions-windows-amd64.exe.gz",
                "label": "",
                "uploader": {
                  "login": "github-actions[bot]",
                  "id": 41898282,
                  "node_id": "MDM6Qm90NDE4OTgyODI=",
                  "avatar_url": "https://avatars.githubusercontent.com/in/15368?v=4",
                  "gravatar_id": "",
                  "url": "https://api.github.com/users/github-actions%5Bbot%5D",
                  "html_url": "https://github.com/apps/github-actions",
                  "followers_url": "https://api.github.com/users/github-actions%5Bbot%5D/followers",
                  "following_url": "https://api.github.com/users/github-actions%5Bbot%5D/following{/other_user}",
                  "gists_url": "https://api.github.com/users/github-actions%5Bbot%5D/gists{/gist_id}",
                  "starred_url": "https://api.github.com/users/github-actions%5Bbot%5D/starred{/owner}{/repo}",
                  "subscriptions_url": "https://api.github.com/users/github-actions%5Bbot%5D/subscriptions",
                  "organizations_url": "https://api.github.com/users/github-actions%5Bbot%5D/orgs",
                  "repos_url": "https://api.github.com/users/github-actions%5Bbot%5D/repos",
                  "events_url": "https://api.github.com/users/github-actions%5Bbot%5D/events{/privacy}",
                  "received_events_url": "https://api.github.com/users/github-actions%5Bbot%5D/received_events",
                  "type": "Bot",
                  "site_admin": false
                },
                "content_type": "application/gzip",
                "state": "uploaded",
                "size": 5121839,
                "download_count": 3,
                "created_at": "2021-09-14T14:04:46Z",
                "updated_at": "2021-09-14T14:04:47Z",
                "browser_download_url": "https://github.com/Shopify/shopify-cli-extensions/releases/download/v0.1.0/shopify-extensions-windows-amd64.exe.gz"
              },
              {
                "url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/assets/44743629",
                "id": 44743629,
                "node_id": "RA_kwDOF4czm84CqrvN",
                "name": "shopify-extensions-windows-amd64.exe.md5",
                "label": "",
                "uploader": {
                  "login": "github-actions[bot]",
                  "id": 41898282,
                  "node_id": "MDM6Qm90NDE4OTgyODI=",
                  "avatar_url": "https://avatars.githubusercontent.com/in/15368?v=4",
                  "gravatar_id": "",
                  "url": "https://api.github.com/users/github-actions%5Bbot%5D",
                  "html_url": "https://github.com/apps/github-actions",
                  "followers_url": "https://api.github.com/users/github-actions%5Bbot%5D/followers",
                  "following_url": "https://api.github.com/users/github-actions%5Bbot%5D/following{/other_user}",
                  "gists_url": "https://api.github.com/users/github-actions%5Bbot%5D/gists{/gist_id}",
                  "starred_url": "https://api.github.com/users/github-actions%5Bbot%5D/starred{/owner}{/repo}",
                  "subscriptions_url": "https://api.github.com/users/github-actions%5Bbot%5D/subscriptions",
                  "organizations_url": "https://api.github.com/users/github-actions%5Bbot%5D/orgs",
                  "repos_url": "https://api.github.com/users/github-actions%5Bbot%5D/repos",
                  "events_url": "https://api.github.com/users/github-actions%5Bbot%5D/events{/privacy}",
                  "received_events_url": "https://api.github.com/users/github-actions%5Bbot%5D/received_events",
                  "type": "Bot",
                  "site_admin": false
                },
                "content_type": "application/octet-stream",
                "state": "uploaded",
                "size": 57,
                "download_count": 0,
                "created_at": "2021-09-14T14:04:47Z",
                "updated_at": "2021-09-14T14:04:47Z",
                "browser_download_url": "https://github.com/Shopify/shopify-cli-extensions/releases/download/v0.1.0/shopify-extensions-windows-amd64.exe.md5"
              }
            ],
            "tarball_url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/tarball/v0.1.0",
            "zipball_url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/zipball/v0.1.0",
            "body": "Initial release for integration testing purposes only."
          }
        JSON
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

    def simulate_non_existing_release
      stub_request(:get, "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/tags/v0.0.0")
        .to_raise(OpenURI::HTTPError.new("404 Not Found", StringIO.new))
    end

    def simulate_release_without_assets
      stub_request(:get, "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/tags/v0.1.0")
        .to_return(status: 200, body: <<~JSON)
          {
            "url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/49531769",
            "assets_url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/releases/49531769/assets",
            "upload_url": "https://uploads.github.com/repos/Shopify/shopify-cli-extensions/releases/49531769/assets{?name,label}",
            "html_url": "https://github.com/Shopify/shopify-cli-extensions/releases/tag/v0.1.0",
            "id": 49531769,
            "author": {
              "login": "t6d",
              "id": 77060,
              "node_id": "MDQ6VXNlcjc3MDYw",
              "avatar_url": "https://avatars.githubusercontent.com/u/77060?v=4",
              "gravatar_id": "",
              "url": "https://api.github.com/users/t6d",
              "html_url": "https://github.com/t6d",
              "followers_url": "https://api.github.com/users/t6d/followers",
              "following_url": "https://api.github.com/users/t6d/following{/other_user}",
              "gists_url": "https://api.github.com/users/t6d/gists{/gist_id}",
              "starred_url": "https://api.github.com/users/t6d/starred{/owner}{/repo}",
              "subscriptions_url": "https://api.github.com/users/t6d/subscriptions",
              "organizations_url": "https://api.github.com/users/t6d/orgs",
              "repos_url": "https://api.github.com/users/t6d/repos",
              "events_url": "https://api.github.com/users/t6d/events{/privacy}",
              "received_events_url": "https://api.github.com/users/t6d/received_events",
              "type": "User",
              "site_admin": false
            },
            "node_id": "RE_kwDOF4czm84C88t5",
            "tag_name": "v0.1.0",
            "target_commitish": "main",
            "name": "v0.1.0",
            "draft": false,
            "prerelease": true,
            "created_at": "2021-09-14T13:43:17Z",
            "published_at": "2021-09-14T14:04:11Z",
            "assets": [],
            "tarball_url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/tarball/v0.1.0",
            "zipball_url": "https://api.github.com/repos/Shopify/shopify-cli-extensions/zipball/v0.1.0",
            "body": "Initial release for integration testing purposes only."
          }
        JSON
    end

    def load_dummy_archive
      path = File.expand_path("../../../fixtures/shopify-extensions.gz", __FILE__)
      raise "Dummy archive not found: #{path}" unless File.file?(path)
      File.read(path)
    end
  end
end
