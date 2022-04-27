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
        property  :metafields, accepts: Array, default: -> { [] }

        def initialize(**_args)
          renderer = ServerConfig::DevelopmentRenderer.find(_args[:type])
          entry = ServerConfig::DevelopmentEntries.find(_args[:template])
          super(
            uuid: !_args[:uuid] ? generate_dev_uuid : _args[:uuid],
            type: _args[:type].downcase,
            user: ServerConfig::User.new,
            development: ServerConfig::Development.new(
              root_dir: _args[:root_dir],
              template: _args[:template],
              renderer: renderer,
              entries: entry
            ),
            capabilities: ServerConfig::Capabilities.new(
              network_access: false
            ),
            metafields: _args[:metafields]
          )
        end

        private

        def generate_dev_uuid
          "dev-#{SecureRandom.uuid}"
        end
      end
    end
  end
end
