# frozen_string_literal: true
require "base64"
require "fileutils"
require "json"
require_relative "beacon_extension_utils/script_config"
require_relative "beacon_extension_utils/script_config_repository"

module Extension
  module Models
    module SpecificationHandlers
      class BeaconExtension < Default
        SCRIPT_FILE = "build/main.js"

        def name
          "Beacon Extension"
        end

        def read_configuration
        end

        def access_config_property(context, ext_config, key, &process_value)
          context.abort(context.message("core.extension.push.beacon_extension.error.missing_config_key_error",
            key)) unless ext_config.key?(key)

          begin
            process_value.nil? ? ext_config[key] : process_value.call(ext_config[key])
          rescue StandardError
            context.abort(context.message("core.extension.push.beacon_extension.error.invalid_config_value_error", key))
          end
        end

        def config(context)
          begin
            ext_config = BeaconExtensionUtils::ScriptConfigYmlRepository.new(ctx: context).get!.content
          rescue StandardError
            context.abort(context.message("core.extension.push.beacon_extension.error.file_read_error",
              BeaconExtensionUtils::ScriptConfigYmlRepository.filename))
          end

          begin
            script_contents = File.read(File.join(context.root, SCRIPT_FILE)).chomp
          rescue
            context.abort(context.message("core.extension.push.beacon_extension.error.file_read_error", SCRIPT_FILE))
          end
          {
            runtime_context: access_config_property(context, ext_config, "runtime_context"),
            serialized_script: Base64.strict_encode64(script_contents),
            runtime_configuration_definition: access_config_property(context, ext_config,
              "configuration") { |config_def_hash| JSON.pretty_generate(config_def_hash) },
            config_version: access_config_property(context, ext_config,
              "version", &:to_s),
          }
        end
      end
    end
  end
end
