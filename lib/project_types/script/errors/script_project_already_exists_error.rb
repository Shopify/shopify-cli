# frozen_string_literal: true

module Script
  class ScriptProjectAlreadyExistsError < StandardError
    def initialize(dir)
      super("#{dir} already exists")
    end
  end
end
