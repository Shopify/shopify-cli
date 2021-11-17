# frozen_string_literal: true
require "base64"
require "fileutils"

module Extension
  module Models
    module SpecificationHandlers
      class TagManagerExtension < Default

        SCRIPT_NAME = 'analytics.js'

        def name
          "Tag Manager Extension"
        end

        def config(context)
          
          filepath = File.join(context.root, SCRIPT_NAME)
          context.abort(context.message("features.argo.missing_file_error")) unless File.exist?(filepath)

          begin
            contents = File.read(filepath).chomp
            {
              src_code: contents,
            }
          rescue StandardError
            context.abort(context.message("features.argo.script_prepare_error"))
          end
        end

        def create(directory_name, context, **_args)
          
          context.root = File.join(context.root, directory_name)
          FileUtils.makedirs(context.root)
          FileUtils.touch(File.join(context.root, SCRIPT_NAME))
        end
      end
    end
  end
end
