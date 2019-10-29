# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class TestSuite
        attr_reader :id, :script

        def initialize(id, script)
          @id = id
          @script = script
        end
      end
    end
  end
end
