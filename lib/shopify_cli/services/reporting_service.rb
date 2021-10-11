module ShopifyCLI
  module Services
    class ReportingService < BaseService
      attr_reader :enable

      def initialize(enable:)
        @enable = enable
        super()
      end

      def call
        ReportingConfigurationController.enable_reporting(enable)
      end
    end
  end
end
