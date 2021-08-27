module Extension
  module Models
    module ServerConfig
      class Extension < Base
        include SmartProperties
        property! :uuid, accepts: String
        property! :type, accepts: String
        property! :user, accepts: ServerConfig::User
        property! :development, accepts: ServerConfig::Development
      end
    end
  end
end
