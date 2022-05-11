module Script
  module Layers
    module Infrastructure
      class ScriptCompiler
        def initialize(script_service)
          @script_service = script_service
        end

        def compile(module_upload_url:)
          @script_service.compile(module_upload_url: module_upload_url)
        end

        def compilation_status(job_id:)
          @script_service.compilation_status(job_id: job_id)
        end
      end
    end
  end
end
