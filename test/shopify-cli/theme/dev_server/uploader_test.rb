# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"

class UploaderTest < Minitest::Test
  def setup
    super
    config = ShopifyCli::Theme::DevServer::Config.from_path(ShopifyCli::ROOT + "/test/fixtures/theme")
    @ctx = TestHelpers::FakeContext.new(root: config.root)
    @theme = ShopifyCli::Theme::DevServer::Theme.new(@ctx, config)
    @uploader = ShopifyCli::Theme::DevServer::Uploader.new(@ctx, @theme)

    ShopifyCli::DB.stubs(:exists?).with(:shop).returns(true)
    ShopifyCli::DB
      .stubs(:get)
      .with(:shop)
      .returns("dev-theme-server-store.myshopify.com")
    ShopifyCli::DB
      .stubs(:get)
      .with(:development_theme_id)
      .returns("12345678")
  end

  def teardown
    super
    @uploader.shutdown
  end

  def test_upload_text_file
    ShopifyCli::AdminAPI.expects(:rest_request).with(
      @ctx,
      shop: @theme.shop,
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
      {},
    ])

    @uploader.upload(@theme["assets/theme.css"])
  end

  def test_upload_binary_file
    ShopifyCli::AdminAPI.expects(:rest_request).with(
      @ctx,
      shop: @theme.shop,
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
      {},
    ])

    @uploader.upload(@theme["assets/logo.png"])
  end

  def test_upload_when_unmodified
    @theme.remote_checksums["assets/theme.css"] = @theme["assets/theme.css"].checksum

    ShopifyCli::AdminAPI.expects(:rest_request).never
    @uploader.upload(@theme["assets/theme.css"])
  end

  def test_fetch_remote_checksums
    ShopifyCli::AdminAPI.expects(:rest_request).with(
      @ctx,
      shop: @theme.shop,
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
      {},
    ])

    @uploader.fetch_remote_checksums!

    assert_equal(@theme["assets/theme.css"].checksum, @theme.remote_checksums["assets/theme.css"])
  end

  def test_upload_from_threads
    @uploader.start_threads

    @theme.liquid_files.each do |file|
      ShopifyCli::AdminAPI.expects(:rest_request).with(
        @ctx,
        shop: @theme.shop,
        path: "themes/#{@theme.id}/assets.json",
        method: "PUT",
        api_version: "unstable",
        body: JSON.generate({
          asset: {
            key: file.relative_path,
            value: file.read,
          },
        })
      ).returns([200, {}, {}])
    end

    @uploader.enqueue_uploads(@theme.liquid_files)
    @uploader.wait_for_uploads!
  end

  def test_theme_files_are_pending_during_upload
    file = @theme.asset_files.first

    @uploader.enqueue_upload(file)
    assert_includes(@theme.pending_files, file)

    @uploader.start_threads
    @uploader.wait_for_uploads!
    assert_empty(@theme.pending_files)
  end

  def test_logs_upload_error
    @uploader.start_threads

    file = @theme.asset_files.first
    @ctx.expects(:puts).once
    ShopifyCli::AdminAPI.expects(:rest_request).raises(RuntimeError.new("oops"))

    @uploader.enqueue_upload(file)
    @uploader.wait_for_uploads!
  end

  def test_upload_theme
    @uploader.start_threads

    expected_size = (@theme.liquid_files + @theme.json_files)
      .reject { |file| @theme.ignore?(file) }
      .size

    ShopifyCli::AdminAPI.expects(:rest_request)
      .at_least(expected_size)
      .returns([200, {}, {}])

    @uploader.upload_theme!
    # Still has pending assets to upload
    refute_empty(@uploader)

    @uploader.wait_for_uploads!
    assert_empty(@uploader)
  end

  def test_backoff_near_api_limit
    @uploader.start_threads
    file = @theme.liquid_files.first

    ShopifyCli::AdminAPI.expects(:rest_request).with(
      @ctx,
      shop: @theme.shop,
      path: "themes/#{@theme.id}/assets.json",
      method: "PUT",
      api_version: "unstable",
      body: JSON.generate({
        asset: {
          key: file.relative_path,
          value: file.read,
        },
      })
    ).returns([
      200,
      {},
      {
        "x-shopify-shop-api-call-limit" => "39/40",
      },
    ])

    @uploader.expects(:sleep).with(2)

    @uploader.enqueue_upload(file)
    @uploader.wait_for_uploads!
  end

  def test_dont_backoff_under_api_limit
    @uploader.start_threads
    file = @theme.liquid_files.first

    ShopifyCli::AdminAPI.expects(:rest_request).with(
      @ctx,
      shop: @theme.shop,
      path: "themes/#{@theme.id}/assets.json",
      method: "PUT",
      api_version: "unstable",
      body: JSON.generate({
        asset: {
          key: file.relative_path,
          value: file.read,
        },
      })
    ).returns([
      200,
      {},
      {
        "x-shopify-shop-api-call-limit" => "5/40",
      },
    ])

    @uploader.expects(:sleep).never

    @uploader.enqueue_upload(file)
    @uploader.wait_for_uploads!
  end

  def test_log_api_errors
    @uploader.start_threads
    file = @theme["sections/footer.liquid"]

    response_body = JSON.generate(
      errors: {
        asset: [
          "An error",
          "Then some\nThis is truncated",
        ],
      }
    )

    ShopifyCli::AdminAPI.expects(:rest_request)
      .raises(ShopifyCli::API::APIRequestClientError.new(
        "message", response: mock(body: response_body)
      ))

    @ctx.expects(:puts).with(<<~EOS.chomp)
      {{red:ERROR}} {{blue:sections/footer.liquid}}:
      \tAn error
      \tThen some
    EOS

    @uploader.enqueue_upload(file)
    @uploader.wait_for_uploads!
  end

  def test_log_api_errors_with_invalid_response_body
    @uploader.start_threads
    file = @theme["sections/footer.liquid"]

    response_body = JSON.generate(
      errors: {
        message: "oops",
      }
    )

    ShopifyCli::AdminAPI.expects(:rest_request)
      .raises(ShopifyCli::API::APIRequestClientError.new(
        "exception message", response: mock(body: response_body)
      ))

    @ctx.expects(:puts).with(<<~EOS.chomp)
      {{red:ERROR}} {{blue:sections/footer.liquid}}:
      \texception message
    EOS

    @uploader.enqueue_upload(file)
    @uploader.wait_for_uploads!
  end

  def test_delays_reporting_errors
    @uploader.start_threads
    file = @theme["sections/footer.liquid"]

    response_body = JSON.generate(
      errors: {
        asset: [
          "An error",
          "Then some",
        ],
      }
    )

    ShopifyCli::AdminAPI.expects(:rest_request)
      .raises(ShopifyCli::API::APIRequestClientError.new(
        "message", response: mock(body: response_body)
      ))

    @ctx.expects(:puts).never

    @uploader.delay_errors!
    @uploader.enqueue_upload(file)
    @uploader.wait_for_uploads!

    # Assert @ctx.puts was not called
    mocha_verify

    @ctx.expects(:puts).with(<<~EOS.chomp)
      {{red:ERROR}} {{blue:sections/footer.liquid}}:
      \tAn error
      \tThen some
    EOS
    @uploader.report_errors!
  end
end
