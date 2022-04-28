module Extension
  module Models
    module ServerConfig
      class Capabilities < Base
        include SmartProperties

        property :network_access, accepts: [true, false], default: false
      end
    end
  end
end
