# frozen_string_literal: true
require "base64"
require "fileutils"

module Extension
  module Models
    module SpecificationHandlers
      class AnalyticsExtension < Default
        SCRIPT_NAME = "analytics.js"

        def name
          "Analytics Extension"
        end

        def create(directory_name, context, **_args)
          context.root = File.join(context.root, directory_name)
          FileUtils.makedirs(context.root)
          FileUtils.touch(File.join(context.root, 'analytics.js'))
        end

        def config(context)
          filepath = File.join(context.root, SCRIPT_NAME)
          context.abort(context.message("features.argo.missing_file_error")) unless File.exist?(filepath)

          begin
            contents = File.read(filepath).chomp
            {
              script: contents,
              serialized_script: Base64.strict_encode64(contents)
            }
          rescue StandardError
            context.abort(context.message("features.argo.script_prepare_error"))
          end
        end

      end
    end
  end
end
