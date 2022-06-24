# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/theme_admin_api_throttler/put_request"
require "shopify_cli/theme/theme_admin_api_throttler/bulk"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class BulkTest < Minitest::Test
        MULTIPLE_THREADS = 1

        def setup
          super
          root = ShopifyCLI::ROOT + "/test/fixtures/theme"

          ShopifyCLI::DB
            .stubs(:get)
            .with(:development_theme_id)
            .returns("12345678")

          # Avoid rest_request call
          ShopifyCLI::Theme::ThemeAdminAPIThrottler::BulkJob
            .any_instance
            .stubs(:rest_request)
            .returns(temp_bulk_response)

          ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("dev-theme-server-store.myshopify.com")

          @ctx = TestHelpers::FakeContext.new(root: root)
          @theme = Theme.new(@ctx, root: root)
          @admin_api = ThemeAdminAPI.new(@ctx, @theme.shop)
        end

        def test_batch_bytesize_upper_bound_with_multiple_threads
          @bulk = Bulk.new(@ctx, @admin_api, pool_size: MULTIPLE_THREADS)

          request_1 = generate_put_request("file1.txt", Bulk::MAX_BULK_BYTESIZE / 3)
          request_2 = generate_put_request("file2.txt", Bulk::MAX_BULK_BYTESIZE / 3)
          request_3 = generate_put_request("file3.txt", Bulk::MAX_BULK_BYTESIZE + 1)

          [request_1, request_2, request_3].each do |request|
            @bulk.enqueue(request)
          end

          @ctx.expects(:debug)
            .with(debug_formatter(2, request_1.size + request_2.size))
          @ctx.expects(:debug)
            .with(debug_formatter(1, request_3.size))
          @bulk.shutdown
        end

        def test_batch_bytesize_upper_bound_with_single_thread
          @bulk = Bulk.new(@ctx, @admin_api)

          request_1 = generate_put_request("file1.txt", Bulk::MAX_BULK_BYTESIZE + 2)
          request_2 = generate_put_request("file2.txt", Bulk::MAX_BULK_BYTESIZE + 3)
          request_3 = generate_put_request("file3.txt", Bulk::MAX_BULK_BYTESIZE + 4)

          [request_1, request_2, request_3].each do |request|
            @bulk.enqueue(request)
          end

          @ctx.expects(:debug)
            .with(debug_formatter(1, request_1.size))
          @ctx.expects(:debug)
            .with(debug_formatter(1, request_2.size))
          @ctx.expects(:debug)
            .with(debug_formatter(1, request_3.size))
          @bulk.shutdown
        end

        def test_batch_num_files_upper_bound_with_single_thread
          @bulk = Bulk.new(@ctx, @admin_api)

          Bulk::MAX_BULK_FILES.times do |n|
            @bulk.enqueue(generate_put_request("file#{n}.txt", 100_000))
          end

          @ctx.expects(:debug)
            .with(debug_formatter(20, 2_000_000))
          @bulk.shutdown
        end

        def test_batch_num_files_upper_bound_with_multiple_threads
          @bulk = Bulk.new(@ctx, @admin_api, pool_size: MULTIPLE_THREADS)

          num_requests = Bulk::MAX_BULK_FILES << 1

          num_requests.times do |n|
            @bulk.enqueue(generate_put_request("file#{n}.txt", 10_000))
          end

          @ctx.expects(:debug)
            .with(debug_formatter(20, Bulk::MAX_BULK_FILES * 10_000))
            .twice
          @bulk.shutdown
        end

        def test_batch_big_test_with_multiple_threads
          @bulk = Bulk.new(@ctx, @admin_api, pool_size: MULTIPLE_THREADS)

          files = 5.times.map do |i|
            size = (Bulk::MAX_BULK_BYTESIZE / 2) - 1000
            generate_put_request("file#{i}.txt", size + i)
          end

          files.each { |file| @bulk.enqueue(file) }

          @ctx.expects(:debug)
            .with(debug_formatter(2, files[0].size + files[1].size))
          @ctx.expects(:debug)
            .with(debug_formatter(2, files[2].size + files[3].size))
          @ctx.expects(:debug)
            .with(debug_formatter(1, files[4].size))
          @bulk.shutdown
        end

        private

        def generate_put_request(name, size)
          req_body = request_body(name)
          path = "themes/#{@theme.id}/assets.json"
          req = PutRequest.new(path, req_body) do |status, body, _response|
            if status == 200
              @ctx.puts(body)
            else
              @ctx.error(body)
            end
          end
          req.stubs(:size).returns(size)
          req
        end

        def request_body(name)
          JSON.generate(
            asset: {
              key: name,
              value: name,
            }
          )
        end

        def temp_bulk_response
          [1234, [], {}]
        end

        def debug_formatter(num_files, size)
          "[BulkJob] size: #{num_files}, bytesize: #{size}"
        end
      end
    end
  end
end
