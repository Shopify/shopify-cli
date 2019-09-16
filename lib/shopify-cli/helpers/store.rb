require 'pstore'

module ShopifyCli
  module Helpers
    class Store
      attr_reader :db

      class << self
        def keys
          new.keys
        end

        def exists?(key)
          new.exists?(key)
        end

        def set(**args)
          new.set(**args)
        end

        def get(key, &block)
          new.get(key, &block)
        end

        def del(*args)
          new.del(*args)
        end

        def clear
          new.clear
        end
      end

      def initialize(path: File.join(ShopifyCli::TEMP_DIR, ".db.pstore"))
        @db = PStore.new(path)
      end

      def keys
        db.transaction(true) { db.roots }
      end

      def exists?(key)
        db.transaction(true) { db.root?(key) }
      end

      def set(**args)
        db.transaction do
          args.each do |key, val|
            if val.nil?
              db.delete(key)
            else
              db[key] = val
            end
          end
        end
      end

      def get(key)
        val = db.transaction(true) { db[key] }
        val = yield if val.nil? && block_given?
        val
      end

      def del(*args)
        db.transaction { args.each { |key| db.delete(key) } }
      end

      def clear
        del(*keys)
      end
    end
  end
end
