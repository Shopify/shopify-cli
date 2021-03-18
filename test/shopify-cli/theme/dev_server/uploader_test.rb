# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"

class UploaderTest < Minitest::Test
  ASSETS_API_URL = "https://dev-theme-server-store.myshopify.com/admin/api/2021-01/themes/123456789/assets.json"

  def setup
    super
    config = ShopifyCli::Theme::DevServer::Config.from_path(ShopifyCli::ROOT + "/test/fixtures/theme")
    @theme = ShopifyCli::Theme::DevServer::Theme.new(config)
    @uploader = ShopifyCli::Theme::DevServer::Uploader.new(@theme)
  end

  def test_upload
    stub_request(:put, ASSETS_API_URL)
      .with(
        body: JSON.generate(
          asset: {
            key: "assets/theme.css",
            attachment: Base64.encode64(File.read("#{ShopifyCli::ROOT}/test/fixtures/theme/assets/theme.css")),
          }
        ),
        headers: {
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "Host" => "dev-theme-server-store.myshopify.com",
          "X-Shopify-Access-Token" => "notapassword",
        }
      )
      .to_return(
        status: 200,
        body: JSON.generate({
          asset: {
            key: "assets/theme.css",
            checksum: Digest::MD5.hexdigest(File.read("#{ShopifyCli::ROOT}/test/fixtures/theme/assets/theme.css")),
          },
        })
      )

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
    stub_request(:get, ASSETS_API_URL)
      .with(
        headers: {
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "Host" => "dev-theme-server-store.myshopify.com",
          "X-Shopify-Access-Token" => "notapassword",
        }
      )
      .to_return(
        status: 200,
        body: JSON.generate({
          assets: [{
            key: "assets/theme.css",
            checksum: Digest::MD5.hexdigest(File.read("#{ShopifyCli::ROOT}/test/fixtures/theme/assets/theme.css")),
          }],
        })
      )

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
