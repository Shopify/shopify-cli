require "securerandom"

module Extension
  module Models
    module ServerConfig
      class Extension < Base
        include SmartProperties

        property! :uuid, accepts: String
        property! :type, accepts: String
        property! :user, accepts: ServerConfig::User
        property! :development, accepts: ServerConfig::Development
        property  :capabilities, accepts: ServerConfig::Capabilities
        property  :extension_points, accepts: Array
        property  :version, accepts: String
        property  :title, accepts: String

        def self.build(uuid: "", template:, type:, root_dir:)
          renderer = ServerConfig::DevelopmentRenderer.find(type)
          entry = ServerConfig::DevelopmentEntries.find(template)
          new(
            uuid: uuid.empty? ? generate_dev_uuid : uuid,
            type: type.downcase,
            user: ServerConfig::User.new,
            development: ServerConfig::Development.new(
              root_dir: root_dir,
              template: template,
              renderer: renderer,
              entries: entry
            ),
            capabilities: ServerConfig::Capabilities.new(
              network_access: false
            ),
          )
        end

        def self.generate_dev_uuid
          "dev-#{SecureRandom.uuid}"
        end
      end
    end
  end
end
