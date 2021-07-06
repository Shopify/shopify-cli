module Extension
  module Features
    class ArgoRuntime
      CHECKOUT_POST_PURCHASE ||= "CHECKOUT_POST_PURCHASE"

      RUNTIMES ||= [
        Runtimes::AdminRuntime.new,
        Runtimes::CheckoutRuntime.new,
      ]

      def cli_package
        raise NotImplementedError
      end

      def supports?(flag)
        available_flags.include?(flag)
      end

      def available_flags
        []
      end

      def self.build(cli_package:, identifier:)
        case identifier
        when CHECKOUT_POST_PURCHASE
          Runtimes::CheckoutPostPurchaseRuntime.new
        else
          RUNTIMES.find { |runtime| runtime.cli_package == cli_package.name }
        end
      end
    end
  end
end
