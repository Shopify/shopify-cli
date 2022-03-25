# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/ignore_helper"

module ShopifyCLI
  module Theme
    class Syncer
      class IgnoreHelperTest < Minitest::Test
        include IgnoreHelper

        attr_reader :ignore_filter, :include_filter

        def test_ignore_operation_when_it_returns_true
          path = mock
          operation = stub(file_path: path)

          expects(:ignore_path?).with(path).returns(true)

          assert(ignore_operation?(operation))
        end

        def test_ignore_operation_when_it_returns_false
          path = mock
          operation = stub(file_path: path)

          expects(:ignore_path?).with(path).returns(false)

          refute(ignore_operation?(operation))
        end

        def test_ignore_file_when_it_returns_true
          path = mock
          file = stub(path: path)

          expects(:ignore_path?).with(path).returns(true)

          assert(ignore_file?(file))
        end

        def test_ignore_file_when_it_returns_false
          path = mock
          file = stub(path: path)

          expects(:ignore_path?).with(path).returns(false)

          refute(ignore_file?(file))
        end

        def test_ignore_path_when_ignored_by_ignore_filter
          path = mock
          @ignore_filter = stub(ignore?: true)
          @include_filter = stub(match?: true)

          assert(ignore_path?(path))
        end

        def test_ignore_path_when_ignored_by_ignore_and_include_filter
          path = mock
          @ignore_filter = stub(ignore?: true)
          @include_filter = stub(match?: false)

          assert(ignore_path?(path))
        end

        def test_ignore_path_when_ignored_by_include_filter
          path = mock
          @ignore_filter = stub(ignore?: false)
          @include_filter = stub(match?: false)

          assert(ignore_path?(path))
        end

        def test_ignore_path_when_path_is_not_ignored
          path = mock
          @ignore_filter = stub(ignore?: false)
          @include_filter = stub(match?: true)

          refute(ignore_path?(path))
        end
      end
    end
  end
end
