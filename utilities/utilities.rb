$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)

module Utilities
  autoload :Docker, "docker"
  autoload :Constants, "constants"
end
