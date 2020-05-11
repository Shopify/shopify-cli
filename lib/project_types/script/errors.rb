# frozen_string_literal: true

module Script
  module Errors
    class InvalidContextError < ScriptProjectError; end
    class ScriptProjectAlreadyExistsError < ScriptProjectError; end
  end
end
