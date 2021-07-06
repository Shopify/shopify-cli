# frozen_string_literal: true
require "test_helper"

module Extension
  module Features
    module Runtimes
      class AdminRuntimeTest < MiniTest::Test
        def test_supports_api_key
          assert(admin_runtime.supports?(:api_key))
        end

        def test_supports_name
          assert(admin_runtime.supports?(:name))
        end

        def test_supports_port
          assert(admin_runtime.supports?(:port))
        end

        def test_supports_public_url
          assert(admin_runtime.supports?(:public_url))
        end

        def test_supports_renderer_version
          assert(admin_runtime.supports?(:renderer_version))
        end

        def test_supports_shop
          assert(admin_runtime.supports?(:shop))
        end

        def test_supports_uuid
          assert(admin_runtime.supports?(:uuid))
        end

        private

        def admin_runtime
          Runtimes::AdminRuntime.new
        end
      end
    end
  end
end
