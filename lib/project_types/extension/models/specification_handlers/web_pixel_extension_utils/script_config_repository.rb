require_relative "script_config"
module Extension
  module Models
    module SpecificationHandlers
      module WebPixelExtensionUtils
        class ScriptConfigRepository
          include SmartProperties
          property! :ctx, accepts: ShopifyCLI::Context

          def active?
            ctx.file_exist?(filename)
          end

          def get!
            raise RuntimeError.new("NoScriptConfigFile"), filename unless active?

            content = ctx.read(filename)
            hash = file_content_to_hash(content)

            from_h(hash)
          end

          def filename
            raise NotImplementedError
          end

          private

          def from_h(hash)
            Extension::Models::SpecificationHandlers::WebPixelExtensionUtils::ScriptConfig.new(content: hash,
              filename: filename)
          end

          def file_content_to_hash(file_content)
            raise NotImplementedError
          end

          def hash_to_file_content(hash)
            raise NotImplementedError
          end
        end

        class ScriptConfigYmlRepository < ScriptConfigRepository
          def self.filename
            "extension.config.yml"
          end

          def filename
            ScriptConfigYmlRepository.filename
          end

          private

          def file_content_to_hash(file_content)
            begin
              hash = YAML.load(file_content)
            rescue Psych::SyntaxError
              raise parse_error
            end
            raise parse_error unless hash.is_a?(Hash)
            hash
          end

          def hash_to_file_content(hash)
            YAML.dump(hash)
          end

          def parse_error
            RuntimeError.new("ScriptConfigParseError #{filename}, serialization_format: \"YAML\" ")
          end
        end
      end
    end
  end
end
