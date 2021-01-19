module Extension
  module Specifications
    class PlaceholderRepository
      def get(identifier)
        Result.error("Extension::Sepcifications.repository not configured")
      end

      def all
        Result.error("Extension::Sepcifications.repository not configured")
      end
    end
  end
end
