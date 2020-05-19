# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class FakeDeployPackageRepository
        def initialize
          @cache = {}
        end

        def create_deploy_package(script, script_content, schema, compiled_type)
          id = id(script.name, compiled_type)
          @cache[id] = Domain::DeployPackage.new(script.id, script, script_content, compiled_type, schema)
        end

        def get_deploy_package(script, compiled_type)
          id = id(script.name, compiled_type)
          if @cache.key?(id)
            @cache[id]
          else
            raise Domain::Errors::DeployPackageNotFoundError
          end
        end

        private

        def id(script_name, compiled_type)
          "#{script_name}.#{compiled_type}"
        end
      end
    end
  end
end
