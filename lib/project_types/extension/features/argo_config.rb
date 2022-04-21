# frozen_string_literal: true

module Extension
  module Features
    class ArgoConfig
      CONFIG_FILE_NAME = "extension.config.yml"

      class << self
        def parse_yaml(context, permitted_keys = [])
          file_name = File.join(context.root, CONFIG_FILE_NAME)

          return {} unless File.size?(file_name)

          begin
            config = YAML.load_file(file_name)

            # `YAML.load_file` returns nil if the file is not empty
            # but does not contain any parsable yml data, e.g. only comments
            # We consider this valid
            return {} if config.nil?

            unless config.is_a?(Hash)
              raise ShopifyCLI::Abort, ShopifyCLI::Context.message("core.yaml.error.not_hash", CONFIG_FILE_NAME)
            end

            config.transform_keys!(&:to_sym)
            assert_valid_config(config, permitted_keys) unless permitted_keys.empty?

            config
          rescue Psych::SyntaxError => e
            raise(
              ShopifyCLI::Abort,
              ShopifyCLI::Context.message("core.yaml.error.invalid", CONFIG_FILE_NAME, e.message)
            )
          end
        end

        private

        def assert_valid_config(config, permitted_keys)
          unpermitted_keys = config.keys.select do |k|
            !permitted_keys.include?(k)
          end

          unless unpermitted_keys.empty?
            raise(
              ShopifyCLI::Abort,
              ShopifyCLI::Context.message(
                "features.argo.config.unpermitted_keys",
                CONFIG_FILE_NAME,
                unpermitted_keys.map { |k| "\n- #{k}" }.join
              )
            )
          end
        end
      end
    end
  end
end
