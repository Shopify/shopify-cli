# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        def get_script(language, extension_point_type, script_name)
          source_file_path = src_code_file(language)
          unless ctx.file_exist?(source_file_path)
            raise Domain::Errors::ScriptNotFoundError.new(extension_point_type, source_file_path)
          end

          Domain::Script.new(script_id(language), script_name, extension_point_type, language)
        end

        def relative_path_to_src
          'src'
        end

        private

        def project_base
          ScriptProject.current.directory
        end

        def src_base
          "#{project_base}/#{relative_path_to_src}"
        end

        def script_id(language)
          "#{relative_path_to_src}/#{file_name(language)}"
        end

        def src_code_file(language)
          "#{src_base}/#{file_name(language)}"
        end

        def file_name(language)
          "script.#{language}"
        end
      end
    end
  end
end
