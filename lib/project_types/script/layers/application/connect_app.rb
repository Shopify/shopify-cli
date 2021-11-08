# frozen_string_literal: true

require "shopify_cli"

module Script
  module Layers
    module Application
      class ConnectApp
        class << self
          def call(script_project_repo:, api_key:, secret:, uuid:)
            script_project_repo.create_env(
              api_key: api_key,
              secret: secret,
              uuid: uuid
            )
          end

          def env_valid?(script_project:)
            return true if script_project.api_key && script_project.api_secret && script_project.uuid_defined?
            false
          end
        end
      end
    end
  end
end
