# frozen_string_literal: true

require "test_helper"
require "timecop"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/theme_admin_api_throttler/put_request"
require "shopify_cli/theme/theme_admin_api_throttler/bulk"


module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class BulkJobTest < Minitest::Test
        def setup
          super

          root = ShopifyCLI::ROOT + "/test/fixtures/theme"
          ShopifyCLI::DB
            .stubs(:get)
            .with(:development_theme_id)
            .returns("12345678")

          ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("dev-theme-server-store.myshopify.com")

          @ctx = TestHelpers::FakeContext.new(root: root)
          @theme = Theme.new(@ctx, root: root)
          @admin_api = ThemeAdminAPI.new(@ctx, @theme.shop)
        end

        def test_perform_success
          @job = BulkJob.new(bulk)
          ShopifyCLI::AdminAPI
            .expects(:rest_request)
            .with(
              @ctx,
              shop: @theme.shop,
              path: "themes/#{@theme.id}/assets/bulk.json",
              method: "PUT",
              api_version: "unstable",
              body: JSON.generate({
                assets: [
                  { key: "file1.txt", value: "file1" },
                ]
              })
            ).returns(
              [
                207,
                {
                  "results" => [
                    {
                      "code" => 200,
                      "body" => {
                        "asset" => {
                          "key" => "file1.txt",
                        }
                      }
                    },
                  ],
                },
                {}
              ]
            )

          @ctx.expects(:puts).with("12:30:59 {{green:Synced }} {{>}} {{blue:update file1.txt}}").once

          time_freeze do
            @job.perform!
          end
        end

        def test_perform_when_bulk_request_error
          @job = BulkJob.new(bulk)
          ShopifyCLI::AdminAPI
            .expects(:rest_request)
            .with(
              @ctx,
              shop: @theme.shop,
              path: "themes/#{@theme.id}/assets/bulk.json",
              method: "PUT",
              api_version: "unstable",
              body: JSON.generate({
                assets: [
                  { key: "file1.txt", value: "file1" },
                ]
              })
            ).returns(
              [
                400,
                {},
                {}
              ]
            )
          @job.expects(:handle_requeue).once
          @job.perform!
        end

        def test_perform_when_asset_update_error
          @job = BulkJob.new(bulk)
          ShopifyCLI::AdminAPI
            .expects(:rest_request)
            .with(
              @ctx,
              shop: @theme.shop,
              path: "themes/#{@theme.id}/assets/bulk.json",
              method: "PUT",
              api_version: "unstable",
              body: JSON.generate({
                assets: [
                  { key: "file1.txt", value: "file1" },
                ]
              })
            ).returns(
              [
                207,
                {
                  "results" => [
                    {
                      "code" => 422,
                      "body" => {
                        "errors" => {
                          "asset" => "Something is wrong with this file!!!",
                        }
                      }
                    },
                  ],
                },
                {}
              ]
            )
          # TODO: determine how to handle
        end

        private

        def bulk
          @bulk ||= stub(
            "Bulk",
            ready?: true,
            consume_put_requests: [generate_put_request("file1", 34_021)],
            admin_api: @admin_api,
          )
        end

        def simulate_operations
          # print error if passed error in block
          # print synced otherwise
        end

        def generate_put_request(name, size, &block)
          body = request_body(name, size)
          path = "themes/#{@theme.id}/assets.json"
          request = stub(
            "PutRequest",
            name: name, # debugging
            method: "PUT",
            body: body,
            size: size,
            path: path,
            bulk_path: path.gsub(/.json$/, "/bulk.json"),
            block: block,
          )
          request
        end

        def request_body(name, size)
          JSON.generate(
            asset: {
              key: "#{name}.txt",
              value: "#{name}",
            }
          )
        end

        def time_freeze(&block)
          time = Time.local(2000, 1, 1, 12, 30, 59)
          Timecop.freeze(time, &block)
        end

        def mock_context_synced_message
          @ctx.stubs(:message)
            .with("theme.serve.operation.status.synced")
            .returns("Synced")
        end

        def mock_context_synced_message
          @ctx.stubs(:message)
            .with("theme.serve.operation.status.error")
            .returns("Error")
        end
      end
    end
  end
end
