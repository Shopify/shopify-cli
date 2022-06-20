# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/theme_admin_api_throttler/put_request"
require "shopify_cli/theme/theme_admin_api_throttler/bulk"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class BulkTest < Minitest::Test
        MULTIPLE_THREADS = 3

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
          @bulk = BulkMock.new(@ctx, @admin_api, pool_size: MULTIPLE_THREADS)

          file1 = generate_put_request("file1.txt", 30_010)
          file2 = generate_put_request("file2.txt", 60_020)
          file3 = generate_put_request("file3.txt", 5_242_880) # exactly max bytesize

          [file1, file2, file3].each do |r|
            @bulk.enqueue(r)
          end

          assert_equal(@bulk.num_calls, 2)
          assert_equal(@bulk.sizes, [90_030, 5_242_880])
          @bulk.shutdown
        end

        def test_batch_bytesize_upper_bound_with_single_thread
          @bulk = BulkMock.new(@ctx, @admin_api)

          file1 = generate_put_request("file1.txt", 5_242_802)
          file2 = generate_put_request("file2.txt", 5_242_803)
          file3 = generate_put_request("file3.txt", 5_242_804) # exactly max bytesize

          [file1, file2, file3].each do |r|
            @bulk.enqueue(r)
          end

          assert_equal(@bulk.num_calls, 3)
          assert_equal(@bulk.sizes, [5_242_802, 5_242_803, 5_242_804])
          @bulk.shutdown
        end

        def test_batch_num_files_upper_bound_with_single_thread
          @bulk = BulkMock.new(@ctx, @admin_api)

          Bulk::MAX_BULK_FILES.times do |n|
            file = generate_put_request("file#{n}.txt", 100_000)
            @bulk.enqueue(file)
          end

          assert_equal(@bulk.num_calls, 1)
          assert_equal(@bulk.sizes, [3_000_000])
          @bulk.shutdown
        end

        def test_batch_num_files_upper_bound_with_multiple_threads
          @bulk = BulkMock.new(@ctx, @admin_api, pool_size: MULTIPLE_THREADS)

          num_requests = Bulk::MAX_BULK_FILES << 1

          num_requests.times do |n|
            file = generate_put_request("file#{n}.txt", 10_000)
            @bulk.enqueue(file)
          end

          assert_equal(@bulk.num_calls, 2)
          assert_equal(@bulk.sizes, [Bulk::MAX_BULK_FILES * 10_000, Bulk::MAX_BULK_FILES * 10_000])
          @bulk.shutdown
        end

        def test_batch_big_test_with_multiple_threads
          @bulk = BulkMock.new(@ctx, @admin_api, pool_size: MULTIPLE_THREADS)

          5.times do |n|
            file = generate_put_request("file#{n}.txt", 3_565_210 + n)
            @bulk.enqueue(file)
          end

          assert_equal(5, @bulk.num_calls)
          assert_equal(@bulk.sizes, [3_565_211, 3_565_212, 3_565_213, 3_565_214, 3_565_215])
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

        class BulkMock < Bulk
          attr_accessor :num_calls, :sizes

          def initialize(ctx, admin_api, pool_size: 20)
            super(ctx, admin_api, pool_size: pool_size)
            @num_calls = 0
            @sizes = []
          end

          def consume_put_requests
            bulk_request = super
            @num_calls += 1
          end
        end
      end
    end
  end
end
