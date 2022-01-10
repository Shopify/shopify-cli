# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      module Languages
        class OtherProjectCreator < ProjectCreator
          def self.config_file
            "script.config.yml"
          end

          def setup_dependencies
            generate_config
            generate_metadata
          end

          private

          # the config is equivalent to TS's script.config.yml
          # ex: https://github.com/Shopify/scripts-apis-examples/blob/master/checkout/typescript/payment-methods/default/script.config.yml
          def generate_config
            content = "---
                version: '2'
                title: #{type} script
                description: #{type} script in other language
                configuration:
                type: object
                fields: {}"

            ctx.write(self.class.config_file, content)
          end

          # the metadata is equivalent to the metadata.json that TS files generate during build
          # and contain the info required for the push package
          def generate_metadata
            filename = "metadata.json"

            content = "{\"schemaVersions\":{\"#{type}\":{\"major\":1,\"minor\":0}},\"flags\":{\"use_msgpack\":true}}"

            ctx.write(filename, content)
          end
        end
      end
    end
  end
end
