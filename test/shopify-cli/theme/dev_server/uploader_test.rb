# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"

class UploaderTest < Minitest::Test
  def setup
    super
    config = ShopifyCli::Theme::DevServer::Config.from_path(ShopifyCli::ROOT + "/test/fixtures/theme")
    @theme = ShopifyCli::Theme::DevServer::Theme.new(config)
    @ctx = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
    @uploader = ShopifyCli::Theme::DevServer::Uploader.new(@ctx, @theme)
  end

  def test_upload_text_file
    ShopifyCli::AdminAPI.expects(:rest_request).with(
      @ctx,
      shop: @theme.config.store,
      path: "themes/#{@theme.id}/assets.json",
      method: "PUT",
      api_version: "unstable",
      body: JSON.generate({
        asset: {
          key: "assets/theme.css",
          value: @theme["assets/theme.css"].read,
        },
      })
    ).returns([
      200,
      {
        "asset" => {
          "key" => "assets/theme.css",
          "checksum" => @theme["assets/theme.css"].checksum,
        },
      },
    ])

    @uploader.upload(@theme["assets/theme.css"])
  end

  def test_upload_binary_file
    ShopifyCli::AdminAPI.expects(:rest_request).with(
      @ctx,
      shop: @theme.config.store,
      path: "themes/#{@theme.id}/assets.json",
      method: "PUT",
      api_version: "unstable",
      body: JSON.generate({
        asset: {
          key: "assets/logo.png",
          attachment: Base64.encode64(@theme["assets/logo.png"].read),
        },
      })
    ).returns([
      200,
      {
        "asset" => {
          "key" => "assets/logo.png",
          "checksum" => @theme["assets/logo.png"].checksum,
        },
      },
    ])

    @uploader.upload(@theme["assets/logo.png"])
  end

  def test_upload_when_unmodified
    @theme.remote_checksums["assets/theme.css"] = @theme["assets/theme.css"].checksum

    ShopifyCli::AdminAPI.expects(:rest_request).never
    @uploader.upload(@theme.assets.first)
  end

  def test_fetch_remote_checksums
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
          "checksum" => @theme["assets/theme.css"].checksum,
        }],
      },
    ])

    @uploader.fetch_remote_checksums!

    assert_equal(@theme["assets/theme.css"].checksum, @theme.remote_checksums["assets/theme.css"])
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
