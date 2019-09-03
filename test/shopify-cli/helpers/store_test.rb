require 'test_helper'

module ShopifyCli
  module Helpers
    class StoreTest < MiniTest::Test
      def test_set
        store = new_store
        store.set(foo: 'bar', life: 42)
        store.db.transaction do
          assert_equal store.db[:foo], 'bar'
          assert_equal store.db[:life], 42
        end
      end

      def test_get
        store = new_store
        assert_equal store.get(:keyone), 'value'
        assert_equal store.get(:keytwo), 42
      end

      def test_keys
        store = new_store
        assert_equal store.keys, [:keyone, :keytwo]
      end

      def test_exists?
        store = new_store
        assert store.exists?(:keyone)
        assert store.exists?(:keytwo)
        refute store.exists?(:nothere)
      end

      def test_del
        store = new_store
        store.set(foo: 'bar', life: 42)
        store.del(:keytwo, :foo)
        assert store.exists?(:keyone)
        assert store.exists?(:life)
        refute store.exists?(:foo)
        refute store.exists?(:keytwo)
      end

      def test_clear
        store = new_store
        store.clear
        refute store.exists?(:keyone)
        refute store.exists?(:keytwo)
      end

      private

      def new_store
        store = Helpers::Store.new(path: File.join(ShopifyCli::TEMP_DIR, ".test_db.pstore"))
        store.clear
        store.db.transaction do
          store.db[:keyone] = 'value'
          store.db[:keytwo] = 42
        end
        store
      end
    end
  end
end
