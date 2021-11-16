# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/syncer"
require "shopify_cli/theme/theme"

module ShopifyCLI
  module Theme
    class SyncerTest < Minitest::Test
      def setup
        super
        root = ShopifyCLI::ROOT + "/test/fixtures/theme"
        @ctx = TestHelpers::FakeContext.new(root: root)
        @theme = Theme.new(@ctx, root: root)
        @syncer = Syncer.new(@ctx, theme: @theme)

        ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
        ShopifyCLI::DB
          .stubs(:get)
          .with(:shop)
          .returns("dev-theme-server-store.myshopify.com")
        ShopifyCLI::DB
          .stubs(:get)
          .with(:development_theme_id)
          .returns("12345678")

        File.any_instance.stubs(:write)

        @syncer.start_threads
      end

      def teardown
        super
        @syncer.shutdown
      end

      def test_update_text_file
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
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

        @syncer.enqueue_updates([@theme["assets/theme.css"]])
        @syncer.wait!
      end

      def test_update_binary_file
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
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

        @syncer.enqueue_updates([@theme["assets/logo.png"]])
        @syncer.wait!
      end

      def test_delete_file
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
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

        @syncer.enqueue_deletes([@theme["assets/theme.css"]])
        @syncer.wait!
      end

      def test_upload_when_unmodified
        @syncer.checksums["assets/theme.css"] = @theme["assets/theme.css"].checksum

        ShopifyCLI::AdminAPI.expects(:rest_request).never

        @syncer.enqueue_updates([@theme["assets/theme.css"]])
        @syncer.wait!
      end

      def test_fetch_checksums
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
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

        @syncer.fetch_checksums!

        assert_equal(@theme["assets/theme.css"].checksum, @syncer.checksums["assets/theme.css"])
      end

      def test_fetch_checksums_with_duplicate_liquid_assets
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
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

        @syncer.fetch_checksums!

        assert(@syncer.checksums["assets/generated.css.liquid"])
        refute(@syncer.checksums["assets/generated.css"])
      end

      def test_update_checksum_after_upload
        ShopifyCLI::AdminAPI.expects(:rest_request).returns([
          200,
          {
            "asset" => {
              "key" => "assets/theme.css",
              "checksum" => "deadbeef",
            },
          },
          {},
        ])

        @syncer.enqueue_updates([@theme["assets/theme.css"]])
        @syncer.wait!

        assert_equal("deadbeef", @syncer.checksums["assets/theme.css"])
      end

      def test_theme_files_are_pending_during_upload
        file = @theme.static_asset_files.first

        @syncer.enqueue_updates([file])
        assert_includes(@syncer.pending_updates, file)

        @syncer.start_threads
        @syncer.wait!
        assert_empty(@syncer.pending_updates)
      end

      def test_logs_upload_error
        @syncer.start_threads

        file = @theme.static_asset_files.first
        @ctx.expects(:puts).once
        ShopifyCLI::AdminAPI.expects(:rest_request).raises(RuntimeError.new("oops"))

        @syncer.enqueue_updates([file])
        @syncer.wait!
      end

      def test_upload_theme
        @syncer.start_threads

        expected_size = @theme.theme_files.size

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .times(expected_size + 1) # +1 for checksums
          .returns([200, {}, {}])

        @syncer.upload_theme!
        assert_empty(@syncer)
      end

      def test_download_theme
        @syncer.start_threads
        @syncer.checksums.replace(@theme.theme_files.map { |file| [file.relative_path.to_s, "OUTDATED"] }.to_h)
        @syncer.checksums.delete("assets/generated.css.liquid")

        expected_size = @theme.theme_files.size - 1 # 1 deleted file

        File.any_instance.expects(:delete).times(1)
        File.any_instance.expects(:write)
          .times(expected_size)
          .with("new content")

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .at_least(expected_size + 1) # +1 for checksums
          .returns([
            200,
            {
              "asset" => {
                "value" => "new content",
              },
            },
            {},
          ])

        @syncer.download_theme!
        assert_empty(@syncer)
      end

      def test_download_theme_with_confirm
        @syncer.confirm = true

        @syncer.start_threads
        @syncer.checksums.replace(@theme.theme_files.map { |file| [file.relative_path.to_s, "OUTDATED"] }.to_h)
        @syncer.checksums.delete("assets/generated.css.liquid")

        expected_size = @theme.theme_files.size
        CLI::UI::Prompt.expects(:confirm).times(expected_size).returns(false)

        File.any_instance.expects(:delete).never
        File.any_instance.expects(:write).never

        # Setup checksum response
        ShopifyCLI::AdminAPI.expects(:rest_request)
          .at_least(1)
          .returns([
            200,
            {
              "assets" => [],
            },
            {},
          ])

        @syncer.download_theme!
        assert_empty(@syncer)
      end

      def test_download_theme_with_ignores
        @syncer.ignore_filter = mock("IgnoreFilter")
        @syncer.ignore_filter.stubs(:ignore?).returns(false)
        @syncer.ignore_filter.expects(:ignore?).with(@theme["assets/generated.css.liquid"]).returns(true)

        @syncer.start_threads
        @syncer.checksums.replace(@theme.theme_files.map { |file| [file.relative_path.to_s, file.checksum] }.to_h)
        @syncer.checksums.delete("assets/generated.css.liquid")

        File.any_instance.expects(:delete).never
        File.any_instance.expects(:write).never

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .at_least(1) # 1 for checksums
          .returns([200, {}, {}])

        @syncer.download_theme!
        assert_empty(@syncer)
      end

      def test_download_theme_without_checksum
        @syncer.start_threads
        @syncer.checksums.replace(@theme.theme_files.map { |file| [file.relative_path.to_s, nil] }.to_h)

        expected_size = @theme.theme_files.size

        File.any_instance.expects(:write)
          .times(expected_size)
          .with("new content")

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .at_least(expected_size + 1) # +1 for checksums
          .returns([
            200,
            {
              "asset" => {
                "value" => "new content",
              },
            },
            {},
          ])

        @syncer.download_theme!
        assert_empty(@syncer)
      end

      def test_upload_theme_with_delayed_low_priority_files
        @syncer.start_threads

        expected_size = (@theme.liquid_files + @theme.json_files).size

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .at_least(expected_size)
          .returns([200, {}, {}])

        @syncer.upload_theme!(delay_low_priority_files: true)
        # Still has pending assets to upload
        refute_empty(@syncer)

        @syncer.wait!
        assert_empty(@syncer)
      end

      def test_upload_theme_deletes_missing_files
        @syncer.start_threads

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
        ShopifyCLI::AdminAPI.expects(:rest_request).with(
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
        ShopifyCLI::AdminAPI.expects(:rest_request)
          .with(@ctx, has_entries(method: "PUT"))
          .never

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .with(@ctx, has_entries(
            method: "DELETE",
            body: JSON.generate(
              asset: {
                key: "assets/removed.css",
              },
            )
          ))
          .returns([200, {}, {}])

        @syncer.upload_theme!
      end

      def test_backoff_near_api_limit
        @syncer.start_threads
        file = @theme.liquid_files.first

        ShopifyCLI::AdminAPI.expects(:rest_request).returns([
          200,
          {},
          {
            "x-shopify-shop-api-call-limit" => "39/40",
          },
        ])

        @syncer.expects(:sleep).with(2)

        @syncer.enqueue_updates([file])
        @syncer.wait!
      end

      def test_dont_backoff_under_api_limit
        @syncer.start_threads
        file = @theme.liquid_files.first

        ShopifyCLI::AdminAPI.expects(:rest_request).returns([
          200,
          {},
          {
            "x-shopify-shop-api-call-limit" => "5/40",
          },
        ])

        @syncer.expects(:sleep).never

        @syncer.enqueue_updates([file])
        @syncer.wait!
      end

      def test_log_api_errors
        @syncer.start_threads
        file = @theme["sections/footer.liquid"]

        response_body = JSON.generate(
          errors: {
            asset: [
              "An error",
              "Then some\nThis is truncated",
            ],
          }
        )

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .raises(ShopifyCLI::API::APIRequestClientError.new(
            "message", response: mock(body: response_body)
          ))

        @ctx.expects(:puts).with(<<~EOS.chomp)
          {{red:ERROR}} {{blue:update sections/footer.liquid}}:
            An error
            Then some
        EOS

        @syncer.enqueue_updates([file])
        @syncer.wait!
      end

      def test_log_api_errors_with_invalid_response_body
        @syncer.start_threads
        file = @theme["sections/footer.liquid"]

        response_body = JSON.generate(
          errors: {
            message: "oops",
          }
        )

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .raises(ShopifyCLI::API::APIRequestClientError.new(
            "exception message", response: mock(body: response_body)
          ))

        @ctx.expects(:puts).with(<<~EOS.chomp)
          {{red:ERROR}} {{blue:update sections/footer.liquid}}:
            exception message
        EOS

        @syncer.enqueue_updates([file])
        @syncer.wait!
      end

      def test_delays_reporting_errors
        @syncer.start_threads
        file = @theme["sections/footer.liquid"]

        response_body = JSON.generate(
          errors: {
            asset: [
              "An error",
              "Then some",
            ],
          }
        )

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .raises(ShopifyCLI::API::APIRequestClientError.new(
            "message", response: mock(body: response_body)
          ))

        @ctx.expects(:puts).never

        @syncer.delay_errors!
        @syncer.enqueue_updates([file])
        @syncer.wait!

        # Assert @ctx.puts was not called
        mocha_verify

        @ctx.expects(:puts).with(<<~EOS.chomp)
          {{red:ERROR}} {{blue:update sections/footer.liquid}}:
            An error
            Then some
        EOS
        @syncer.report_errors!
      end
    end
  end
end
