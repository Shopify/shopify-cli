# frozen_string_literal: true

require "test_helper"

require "shopify_cli/theme/syncer"
require "shopify_cli/theme/development_theme"

module ShopifyCLI
  module Theme
    class Syncer
      class DownloaderTest < Minitest::Test
        include TestHelpers::FakeDB

        def setup
          super

          stubs_cli_db(:shop, shop)
          stubs_cli_db(:development_theme_id, theme.id)
        end

        def test_download_theme
          theme
            .theme_files
            .reject { |file| file.relative_path == "assets/generated.css.liquid" }
            .each { |file| syncer.checksums[file.relative_path] = "OUTDATED" }

          expected_size = theme.theme_files.size - 1 # -1 deleted file

          File
            .any_instance
            .expects(:delete)
            .times(1)
          File
            .any_instance
            .expects(:write)
            .times(expected_size)
            .with("new content")

          ShopifyCLI::AdminAPI
            .expects(:rest_request)
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

          syncer.start_threads
          downloader.download!

          assert_empty(syncer)
        end

        private

        def downloader
          @downloader ||= Downloader.new(syncer, true) {}
        end

        def syncer
          @syncer ||= Syncer.new(ctx, theme: theme, stable: true).tap do |syncer|
            syncer.stubs(:wait).returns(nil)
            syncer.stubs(:theme_created_at_runtime?).returns(false)
          end
        end

        def theme
          @theme ||= Theme.new(ctx, id: "12345678", root: root).tap do |theme|
            theme.stubs(:shop).returns(shop)
          end
        end

        def ctx
          @ctx ||= TestHelpers::FakeContext.new(root: root)
        end

        def root
          @root ||= ShopifyCLI::ROOT + "/test/fixtures/theme"
        end

        def shop
          @shop ||= "dev-theme-server-store.myshopify.com"
        end
      end
    end
  end
end
