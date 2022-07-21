module Extension
  module Tasks
    class FetchSpecifications
      include ShopifyCLI::MethodObject

      property :context
      property :api_key

      def call
        # TODO: remove me when SFR gets merged
        response = [
          {
            "name" => "Online Store - App Theme Extension",
            "identifier" => "theme_app_extension",
            "options" => { "managementExperience" => "cli" },
            "features" => { "argo" => nil },
          },
        ]

        context.abort(context.message("tasks.errors.parse_error")) if response.nil?

        response.reject do |line|
          ::Extension::Features::Runtimes::CheckoutUiExtension::IDENTIFIERS.include?(line["identifier"].upcase)
        end
      end
    end
  end
end
