module Extension
  module Models
    module ServerConfig
      class User < Base
        include SmartProperties
        property! :metafields, accepts: Array, default: -> { [] }
      end
    end
  end
end
