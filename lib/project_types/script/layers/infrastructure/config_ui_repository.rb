# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ConfigUiRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        def create_config_ui(filename, content)
          File.write(filename, content)

          Domain::ConfigUi.new(
            filename: filename,
            content: content,
          )
        end

        def get_config_ui(filename)
          return nil unless filename

          path = File.join(ctx.root, filename)
          raise Domain::Errors::MissingSpecifiedConfigUiDefinitionError, filename unless File.exist?(path)

          content = File.read(path)
          raise Domain::Errors::InvalidConfigUiDefinitionError, filename unless valid_config_ui?(content)

          Domain::ConfigUi.new(
            filename: filename,
            content: content,
          )
        end

        private

        def valid_config_ui?(raw_yaml)
          require "yaml" # takes 20ms, so deferred as late as possible.
          YAML.safe_load(raw_yaml)
          true
        rescue Psych::SyntaxError
          false
        end
      end
    end
  end
end
