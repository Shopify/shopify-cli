require "test_helper"

module ShopifyCLI
  module Services
    class ReportingServiceTest < MiniTest::Test
      def test_it_persists_the_configuration
        # Given
        enable = false
        ReportingConfigurationController.expects(:enable_reporting).with(enable)

        # When/Then
        ReportingService.call(enable: enable)
      end
    end
  end
end
