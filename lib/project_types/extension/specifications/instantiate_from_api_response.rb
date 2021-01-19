module Extension
  module Specifications
    class InstantiateFromApiResponse
      include MethodObject

      def call(api_responses)
        transform(api_responses) do |api_response|
          Specification.new do |s|
            s.name = api_response.fetch(:name)
            s.identifier = api_response.fetch(:identifier)
          end
        end
      end
    end
  end
end
