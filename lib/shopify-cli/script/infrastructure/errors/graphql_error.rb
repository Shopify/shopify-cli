# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Infrastructure
      class GraphqlError < StandardError
        def initialize(msg)
          super(msg)
        end
      end
    end
  end
end
