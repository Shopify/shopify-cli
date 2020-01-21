# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class DependencyError < StandardError
        def initialize(name)
          super("No dependency support for #{name}")
        end
      end
    end
  end
end
