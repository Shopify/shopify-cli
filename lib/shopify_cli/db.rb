require "pstore"
require "forwardable"

module ShopifyCLI
  # Persists transient data like access tokens that may be cleared
  # when user clears their session
  #
  # All of the instance methods documented here can be used as class methods. All class
  # methods are forwarded to a new instance of the database, pointing at the default
  # path.
  class DB
    extend SingleForwardable
    def_delegators :new, :keys, :exists?, :set, :get, :del, :clear

    attr_reader :db # :nodoc:

    def initialize(path: File.join(ShopifyCLI.cache_dir, ".db.pstore")) # :nodoc:
      @db = PStore.new(path)
    end

    # Get all keys that exist in the database.
    #
    # #### Returns
    # - `keys`: an array of string or symbol keys that exist in the database
    #
    # #### Usage
    #
    #   ShopifyCLI::DB.keys
    #
    def keys
      db.transaction(true) { db.roots }
    end

    # Check to see if a key exists in the database, the key will only exist if it
    # has a value so if the key exists then there is also a value.
    #
    # #### Parameters
    # - `key`: a string or a symbol representation of a key that is stored in the DB
    #
    # #### Returns
    # - `exists`: a boolean value if the key exists in the database
    #
    # #### Usage
    #
    #   exists = ShopifyCLI::DB.exists?('shopify_exchange_token')
    #
    def exists?(key)
      db.transaction(true) { db.root?(key) }
    end

    # Persist a value by key in the local storage
    #
    # #### Parameters
    # - `**args`: a hash of keys and values to persist in the database
    #
    # #### Usage
    #
    #   ShopifyCLI::DB.set(shopify_exchange_token: 'token', metric_consent: true)
    #
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

    # Gets a value from the DB that is associated with the supplied key
    #
    # #### Parameters
    # - `key`: a string or a symbol representation of a key that is stored in the DB
    #
    # #### Returns
    # - `value`: will be the previously saved value or nil if the key does not exist
    #   in the database.
    #
    # #### Usage
    #
    #   ShopifyCLI::DB.get(:shopify_exchange_token)
    #
    def get(key)
      val = db.transaction(true) { db[key] }
      val = yield if val.nil? && block_given?
      val
    end

    # Deletes a value from the local storage
    #
    # #### Parameters
    # - `*args`: an array of strings or symbols that are keys to be removed from the database
    #
    # #### Usage
    #
    #   ShopifyCLI::DB.del(:shopify_exchange_token)
    #
    def del(*args)
      db.transaction { args.each { |key| db.delete(key) } }
    end

    # Drops all keys from the database.
    #
    # #### Usage
    #
    #   ShopifyCLI::DB.clear
    #
    def clear
      del(*keys)
    end
  end
end
