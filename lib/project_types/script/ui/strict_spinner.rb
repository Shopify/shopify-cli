# typed: ignore
# frozen_string_literal: true

require "shopify_cli"

module Script
  module UI
    module StrictSpinner
      def self.spin(title, auto_debrief: false)
        exception = nil
        CLI::UI::Spinner.spin(title, auto_debrief: auto_debrief) do |*args|
          begin
            yield(*args)
          rescue StandardError => e
            exception = e
            CLI::UI::Spinner::TASK_FAILED
          end
        end
        raise exception if exception
      end
    end
  end
end
