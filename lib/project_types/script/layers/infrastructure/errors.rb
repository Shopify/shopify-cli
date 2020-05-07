# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Errors
        class DependencyError < ScriptProjectError; end
        class DependencyInstallError < ScriptProjectError; end
        class TestError < ScriptProjectError; end
      end
    end
  end
end
