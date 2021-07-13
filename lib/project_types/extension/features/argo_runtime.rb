module Extension
  module Features
    class ArgoRuntime
      RUNTIMES = [
        Runtimes::Admin.new,
        Runtimes::CheckoutPostPurchase.new,
        Runtimes::CheckoutUiExtension.new,
      ]

      def self.find(cli_package:, identifier:)
        RUNTIMES.find { |runtime| runtime.active_runtime?(cli_package, identifier) }
      end
    end
  end
end
