# frozen_string_literal: true

module ShopifyCli
  module Resources
    class EnvFile
      include SmartProperties
      FILENAME = ".env"
      KEY_MAP = {
        "SHOPIFY_API_KEY" => :api_key,
        "SHOPIFY_API_SECRET" => :secret,
        "SHOP" => :shop,
        "SCOPES" => :scopes,
        "HOST" => :host,
      }

      class << self
        def read(directory = Dir.pwd)
          env_file_path = File.join(directory, ".env")
          read_env_file(env_file_path)
            .then(&method(:new))
            .unwrap { |error| raise error }
        end

        def parse_external_env(directory = Dir.pwd)
          env_file_path = File.join(directory, ".env")
          read_env_file(env_file_path).unwrap { |error| raise error }
        end

        private

        def read_env_file(path)
          ReadEnvFile
            .call(path, transform_keys: ->(key) { KEY_MAP.fetch(key, key) })
            .then(&method(:restructure_variables))
        end

        def restructure_variables(variables)
          variables.each_with_object({ extra: {} }) do |(name, value), restructured_variables|
            if properties.keys.include?(name)
              restructured_variables[name] = value
            else
              restructured_variables[:extra][name] = value
            end
          end
        end
      end

      property :api_key, required: true
      property :secret, required: true
      property :shop
      property :scopes
      property :host
      property :extra, default: -> { {} }

      def to_h
        out = {}
        KEY_MAP.each do |key, value|
          out[key] = send(value).to_s if send(value)
        end
        extra.each do |key, value|
          out[key] = value.to_s
        end
        out
      end

      def write(ctx)
        WriteEnvFile
          .call(to_h, path: FILENAME, ctx: ctx)
          .unwrap { |error| raise error }
      end

      def update(ctx, field, value)
        self[field] = value
        write(ctx)
      end
    end
  end
end
