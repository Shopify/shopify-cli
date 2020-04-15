require 'test_helper'

module ShopifyCli
  class DBTest < MiniTest::Test
    def test_set
      db = new_db
      db.set(foo: 'bar', life: 42)
      db.db.transaction do
        assert_equal db.db[:foo], 'bar'
        assert_equal db.db[:life], 42
      end
    end

    def test_get
      db = new_db
      assert_equal db.get(:keyone), 'value'
      assert_equal db.get(:keytwo), 42
    end

    def test_keys
      db = new_db
      assert_equal db.keys, [:keyone, :keytwo]
    end

    def test_exists?
      db = new_db
      assert db.exists?(:keyone)
      assert db.exists?(:keytwo)
      refute db.exists?(:nothere)
    end

    def test_del
      db = new_db
      db.set(foo: 'bar', life: 42)
      db.del(:keytwo, :foo)
      assert db.exists?(:keyone)
      assert db.exists?(:life)
      refute db.exists?(:foo)
      refute db.exists?(:keytwo)
    end

    def test_clear
      db = new_db
      db.clear
      refute db.exists?(:keyone)
      refute db.exists?(:keytwo)
    end

    private

    def new_db
      db = DB.new(path: File.join(ShopifyCli::TEMP_DIR, ".test_db.pdb"))
      db.clear
      db.db.transaction do
        db.db[:keyone] = 'value'
        db.db[:keytwo] = 42
      end
      db
    end
  end
end
