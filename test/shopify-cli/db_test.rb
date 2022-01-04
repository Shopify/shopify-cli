# typed: ignore
require "test_helper"

module ShopifyCLI
  class DBTest < MiniTest::Test
    def test_set
      db = new_db
      db.set(foo: "bar", life: 42)
      db.db.transaction do
        assert_equal("bar", db.db[:foo])
        assert_equal(42, db.db[:life])
      end
    end

    def test_get
      db = new_db
      assert_equal("value", db.get(:keyone))
      assert_equal(42, db.get(:keytwo))
    end

    def test_keys
      db = new_db
      assert_equal([:keyone, :keytwo], db.keys)
    end

    def test_exists?
      db = new_db
      assert db.exists?(:keyone)
      assert db.exists?(:keytwo)
      refute db.exists?(:nothere)
    end

    def test_del
      db = new_db
      db.set(foo: "bar", life: 42)
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
      db = DB.new(path: File.join(ShopifyCLI::TEMP_DIR, ".test_db.pdb"))
      db.clear
      db.db.transaction do
        db.db[:keyone] = "value"
        db.db[:keytwo] = 42
      end
      db
    end
  end
end
