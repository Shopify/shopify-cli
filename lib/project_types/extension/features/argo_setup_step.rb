# frozen_string_literal: true

module Extension
  module Features
    class ArgoSetupStep
      include SmartProperties

      property! :step
      property! :can_fail, accepts: [true, false], reader: :can_fail?

      def call(context, identifier, directory_name, js_system)
        step_result = step.call(context, identifier, directory_name, js_system)
        can_fail? ? step_result : true
      rescue ShopifyCLI::Abort => e
        context.puts(e.message)
        false
      rescue StandardError => e
        context.puts("{{x}} #{e.message}")
        false
      end

      def self.default(&block)
        ArgoSetupStep.new(step: block, can_fail: true)
      end

      def self.always_successful(&block)
        ArgoSetupStep.new(step: block, can_fail: false)
      end
    end
  end
end
