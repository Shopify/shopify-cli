# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"

class UploaderTest < Minitest::Test
  ASSETS_API_URL = "https://dev-theme-server-store.myshopify.com/admin/api/unstable/themes/123456789/assets.json"

  def setup
    super
    config = ShopifyCli::Theme::DevServer::Config.from_path(ShopifyCli::ROOT + "/test/fixtures/theme")
    @theme = ShopifyCli::Theme::DevServer::Theme.new(config)
    @ctx = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
    @uploader = ShopifyCli::Theme::DevServer::Uploader.new(@ctx, @theme)
  end

  def test_upload
    ShopifyCli::AdminAPI.expects(:rest_request).with(
      @ctx,
      shop: @theme.config.store,
      path: "themes/#{@theme.id}/assets.json",
      method: "PUT",
      api_version: "unstable",
      body: JSON.generate({
        asset: {
          key: "assets/theme.css",
          attachment: Base64.encode64(File.read("#{ShopifyCli::ROOT}/test/fixtures/theme/assets/theme.css")),
        },
      })
    ).returns([
      200,
      {
        "asset" => {
          "key" => "assets/theme.css",
          "checksum" => Digest::MD5.hexdigest(File.read("#{ShopifyCli::ROOT}/test/fixtures/theme/assets/theme.css")),
        },
      },
    ])

    @uploader.upload(@theme["assets/theme.css"])
  end

  def test_upload_when_unmodified
    @theme.checksums["assets/theme.css"] = Digest::MD5.hexdigest(File.read(
      "#{ShopifyCli::ROOT}/test/fixtures/theme/assets/theme.css"
    ))

    assert_not_requested(:put, ASSETS_API_URL) do
      @uploader.upload(@theme.assets.first)
    end
  end

  def test_fetch_checksums
    ShopifyCli::AdminAPI.expects(:rest_request).with(
      @ctx,
      shop: @theme.config.store,
      path: "themes/#{@theme.id}/assets.json",
      api_version: "unstable",
    ).returns([
      200,
      {
        "assets" => [{
          "key" => "assets/theme.css",
          "checksum" => Digest::MD5.hexdigest(File.read("#{ShopifyCli::ROOT}/test/fixtures/theme/assets/theme.css")),
        }],
      },
    ])

    @uploader.fetch_checksums!

    assert_equal("d41d8cd98f00b204e9800998ecf8427e", @theme.checksums["assets/theme.css"])
  end

  def test_upload_from_threads
    @uploader.start_threads

    file = @theme.assets.first
    @uploader.expects(:upload).with(file).times(10)

    @uploader.enqueue_uploads([file] * 10)
    @uploader.wait_for_uploads!

  ensure
    @uploader.shutdown
  end

  def test_theme_files_are_pending_during_upload
    file = @theme.assets.first

    @uploader.enqueue_upload(file)
    assert_includes(@theme.pending_files, file)

  ensure
    @uploader.shutdown
  end
end
