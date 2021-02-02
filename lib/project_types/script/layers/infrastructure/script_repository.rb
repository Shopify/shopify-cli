# frozen_string_literal: true

module Script
  module Layers
    module Infrastructure
      class ScriptRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCli::Context

        def get_script(language, extension_point_type, script_name)
          unless ctx.file_exist?(src_code_file)
            raise Domain::Errors::ScriptNotFoundError.new(extension_point_type, src_code_file)
          end

          Domain::Script.new(script_id, script_name, extension_point_type, language)
        end

        def relative_path_to_src
          "src"
        end

        private

        def project_base
          ScriptProject.current.directory
        end

        def src_base
          "#{project_base}/#{relative_path_to_src}"
        end

        def script_id
          "#{relative_path_to_src}/#{file_name}"
        end

        def src_code_file
          "#{src_base}/#{file_name}"
        end

        def file_name
          "script.ts"
        end
      end
    end
  end
end
