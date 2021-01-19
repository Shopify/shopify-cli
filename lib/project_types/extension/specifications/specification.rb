module Extension
  module Specifications
    class Specification
      include SmartProperties

      property! :name
      property! :identifier
      property :features
      property :options
      property :overrides
    end
  end
end
