module Extension
  module Tasks
    class FetchSpecifications
      include ShopifyCli::MethodObject

      property :context
      property :api_key

      def call
        # TODO: Need a way to disable this for e.g. extension create
        cache(api_key) do
          response = ShopifyCli::PartnersAPI
            .query(context, "fetch_specifications", api_key: api_key)
            .dig("data", "extensionSpecifications")
          context.abort(context.message("tasks.errors.parse_error")) if response.nil?
          response
        end
      end

      private

      def cache(api_key)
        specifications_dir = File.join(ShopifyCli.cache_dir, "specifications")
        FileUtils.mkdir_p(specifications_dir)
        filename = File.join(specifications_dir, "#{api_key}.json")

        begin
          if File.file?(filename) && File.mtime(filename) > Time.now - 86400
            # Load from the cache
            context.debug("cache hit: loading from #{filename}")
            return JSON.parse(File.read(filename))
          end
        rescue JSON::JSONError
        end

        context.debug("cache miss: fetching specifications")
        result = yield

        context.debug("cache miss: writing to #{filename}")
        File.write(filename, JSON.dump(result))
        result
      end
    end
  end
end
