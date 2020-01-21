require 'cli/ui'

module ShopifyCli
  module UI
    module RequirementSpinner
      def self.spin(title, auto_debrief: false, &block)
        sg = CLI::UI::SpinGroup.new(auto_debrief: auto_debrief)
        sg.add(title, &block)
        sg.wait
        error = sg.exceptions.first
        raise(ShopifyCli::Abort, error.message) unless error.nil?
      end
    end
  end
end
