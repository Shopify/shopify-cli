# frozen_string_literal: true
module Script
  module Layers
    module Infrastructure
      class RustTaskRunner
        attr_reader :ctx, :script_name

        def initialize(ctx, script_name)
          @ctx = ctx
          @script_name = script_name
        end

        def dependencies_installed?
          true
        end

        def install_dependencies
        end
      end
    end
  end
end
