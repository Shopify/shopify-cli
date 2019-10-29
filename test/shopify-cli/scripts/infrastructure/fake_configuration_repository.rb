module ShopifyCli::ScriptModule
  module Infrastructure
    class FakeConfigurationRepository
      def initialize
        @cache = {}
        @schema =
          <<~GRAPHQL
            input Configuration {
              _: Boolean
            }

            type Query {
              configuration: Configuration
            }
          GRAPHQL
      end

      def create_configuration(extension_point, script_name)
        id = "#{extension_point.type}/#{script_name}"
        @cache[id] = ShopifyCli::ScriptModule::Domain::Configuration.new(id, "configuration.schema", @schema, nil)
      end

      def get_configuration(extension_point_type, script_name)
        id = "#{extension_point_type}/#{script_name}"
        if @cache.key?(id)
          @cache[id]
        else
          raise ShopifyCli::ScriptModule::Domain::ConfigurationFileNotFoundError.new(script_name, id)
        end
      end
    end
  end
end
