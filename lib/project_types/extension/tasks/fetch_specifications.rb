module Extension
  module Tasks
    class FetchSpecifications
      include ShopifyCLI::MethodObject

      property :context
      property :api_key

      def call
        response = ShopifyCLI::PartnersAPI
          .query(context, "fetch_specifications", api_key: api_key)
          .dig("data", "extensionSpecifications")
        context.abort(context.message("tasks.errors.parse_error")) if response.nil?
        response
      end
    end
  end
end
