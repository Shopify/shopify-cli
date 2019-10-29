# frozen_string_literal: true

require "shopify_cli"

module ShopifyCli
  module ScriptModule
    module Application
      class GenerateFromSchema
        def self.generate_config_from_schema(extension_point_type, script_name)
          configuration_repository = Infrastructure::ConfigurationRepository.new
          configuration = configuration_repository.get_configuration(extension_point_type, script_name)
          configuration.generate_glue_code!(Infrastructure::GraphQLTypeScriptBuilder.new)
          configuration_repository.update_configuration(configuration)
        end
      end
    end
  end
end
