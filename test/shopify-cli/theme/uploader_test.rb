# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/uploader"
require "shopify-cli/theme/theme"

module ShopifyCli
  module Theme
    class UploaderTest < Minitest::Test
      def setup
        super
        root = ShopifyCli::ROOT + "/test/fixtures/theme"
        @ctx = TestHelpers::FakeContext.new(root: root)
        @theme = Theme.new(@ctx, root: root)
        @uploader = Uploader.new(@ctx, theme: @theme)

        ShopifyCli::DB.stubs(:exists?).with(:shop).returns(true)
        ShopifyCli::DB
          .stubs(:get)
          .with(:shop)
          .returns("dev-theme-server-store.myshopify.com")
        ShopifyCli::DB
          .stubs(:get)
          .with(:development_theme_id)
          .returns("12345678")

        @uploader.start_threads
      end

      def teardown
        super
        @uploader.shutdown
      end

      def test_update_text_file
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

        @uploader.enqueue_updates([@theme["assets/theme.css"]])
        @uploader.wait!
      end

      def test_update_binary_file
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

        @uploader.enqueue_updates([@theme["assets/logo.png"]])
        @uploader.wait!
      end

      def test_delete_file
        ShopifyCli::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          method: "DELETE",
          api_version: "unstable",
          body: JSON.generate({
            asset: {
              key: "assets/theme.css",
            },
          })
        ).returns([
          200,
          {
            "message": "assets/theme.css was successfully deleted",
          },
          {},
        ])

        @uploader.enqueue_deletes([@theme["assets/theme.css"]])
        @uploader.wait!
      end

      def test_upload_when_unmodified
        @uploader.checksums["assets/theme.css"] = @theme["assets/theme.css"].checksum

        ShopifyCli::AdminAPI.expects(:rest_request).never

        @uploader.enqueue_updates([@theme["assets/theme.css"]])
        @uploader.wait!
      end

      def test_fetch_checksums
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

        @uploader.fetch_checksums!

        assert_equal(@theme["assets/theme.css"].checksum, @uploader.checksums["assets/theme.css"])
      end

      def test_fetch_checksums_with_duplicate_liquid_assets
        ShopifyCli::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          api_version: "unstable",
        ).returns([
          200,
          {
            "assets" => [
              {
                "key" => "assets/generated.css",
                "checksum" => @theme["assets/generated.css.liquid"].checksum,
              },
              {
                "key" => "assets/generated.css.liquid",
                "checksum" => @theme["assets/generated.css.liquid"].checksum,
              },
            ],
          },
          {},
        ])

        @uploader.fetch_checksums!

        assert(@uploader.checksums["assets/generated.css.liquid"])
        refute(@uploader.checksums["assets/generated.css"])
      end

      def test_update_checksum_after_upload
        ShopifyCli::AdminAPI.expects(:rest_request).returns([
          200,
          {
            "asset" => {
              "key" => "assets/theme.css",
              "checksum" => "deadbeef",
            },
          },
          {},
        ])

        @uploader.enqueue_updates([@theme["assets/theme.css"]])
        @uploader.wait!

        assert_equal("deadbeef", @uploader.checksums["assets/theme.css"])
      end

      def test_theme_files_are_pending_during_upload
        file = @theme.asset_files.first

        @uploader.enqueue_updates([file])
        assert_includes(@uploader.pending_updates, file)

        @uploader.start_threads
        @uploader.wait!
        assert_empty(@uploader.pending_updates)
      end

      def test_logs_upload_error
        @uploader.start_threads

        file = @theme.asset_files.first
        @ctx.expects(:puts).once
        ShopifyCli::AdminAPI.expects(:rest_request).raises(RuntimeError.new("oops"))

        @uploader.enqueue_updates([file])
        @uploader.wait!
      end

      def test_upload_theme
        @uploader.start_threads

        expected_size = @theme.theme_files.size

        ShopifyCli::AdminAPI.expects(:rest_request)
          .times(expected_size + 1) # +1 for checksums
          .returns([200, {}, {}])

        @uploader.upload_theme!
        assert_empty(@uploader)
      end

      def test_upload_theme_with_delayed_low_priority_files
        @uploader.start_threads

        expected_size = (@theme.liquid_files + @theme.json_files).size

        ShopifyCli::AdminAPI.expects(:rest_request)
          .at_least(expected_size)
          .returns([200, {}, {}])

        @uploader.upload_theme!(delay_low_priority_files: true)
        # Still has pending assets to upload
        refute_empty(@uploader)

        @uploader.wait!
        assert_empty(@uploader)
      end

      def test_upload_theme_deletes_missing_files
        @uploader.start_threads

        expected_files = @theme.theme_files

        response_assets = expected_files.map do |file|
          {
            "key" => file.relative_path.to_s,
            "checksum" => file.checksum,
          }
        end

        # Add a file that was removed locally
        response_assets << {
          "key" => "assets/removed.css",
          "checksum" => "deadbeef",
        }

        # Checksum request
        ShopifyCli::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: @theme.shop,
          path: "themes/#{@theme.id}/assets.json",
          api_version: "unstable",
        ).returns([
          200,
          { "assets" => response_assets },
          {},
        ])

        # Other assets have matching checksum, so should not be uploaded
        ShopifyCli::AdminAPI.expects(:rest_request)
          .with(@ctx, has_entries(method: "PUT"))
          .never

        ShopifyCli::AdminAPI.expects(:rest_request)
          .with(@ctx, has_entries(
            method: "DELETE",
            body: JSON.generate(
              asset: {
                key: "assets/removed.css",
              },
            )
          ))
          .returns([200, {}, {}])

        @uploader.upload_theme!
      end

      def test_backoff_near_api_limit
        @uploader.start_threads
        file = @theme.liquid_files.first

        ShopifyCli::AdminAPI.expects(:rest_request).returns([
          200,
          {},
          {
            "x-shopify-shop-api-call-limit" => "39/40",
          },
        ])

        @uploader.expects(:sleep).with(2)

        @uploader.enqueue_updates([file])
        @uploader.wait!
      end

      def test_dont_backoff_under_api_limit
        @uploader.start_threads
        file = @theme.liquid_files.first

        ShopifyCli::AdminAPI.expects(:rest_request).returns([
          200,
          {},
          {
            "x-shopify-shop-api-call-limit" => "5/40",
          },
        ])

        @uploader.expects(:sleep).never

        @uploader.enqueue_updates([file])
        @uploader.wait!
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
          {{red:ERROR}} {{blue:update sections/footer.liquid}}:
            An error
            Then some
        EOS

        @uploader.enqueue_updates([file])
        @uploader.wait!
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
          {{red:ERROR}} {{blue:update sections/footer.liquid}}:
            exception message
        EOS

        @uploader.enqueue_updates([file])
        @uploader.wait!
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
        @uploader.enqueue_updates([file])
        @uploader.wait!

        # Assert @ctx.puts was not called
        mocha_verify

        @ctx.expects(:puts).with(<<~EOS.chomp)
          {{red:ERROR}} {{blue:update sections/footer.liquid}}:
            An error
            Then some
        EOS
        @uploader.report_errors!
      end
    end
  end
end
