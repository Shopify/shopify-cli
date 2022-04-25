# frozen_string_literal: true
require "base64"
require "shopify_cli"
require "semantic/semantic"

module Extension
  module Features
    class Argo
      include SmartProperties

      property! :git_template, converts: :to_str
      property! :renderer_package_name, converts: :to_str

      SCRIPT_PATH = %w(build main.js).freeze

      YARN_INSTALL_COMMAND = %w(install).freeze
      YARN_INSTALL_PARAMETERS = %w(--silent).freeze
      YARN_RUN_COMMAND = %w(run).freeze
      YARN_RUN_SCRIPT_NAME = %w(build).freeze
      private_constant :YARN_INSTALL_COMMAND, :YARN_INSTALL_PARAMETERS, :YARN_RUN_COMMAND, :YARN_RUN_SCRIPT_NAME

      def create(directory_name, identifier, context)
        Features::ArgoSetup.new(git_template: git_template).call(directory_name, identifier, context)
      end

      def config(context, include_renderer_version: true)
        filepath = File.join(context.root, SCRIPT_PATH)
        context.abort(context.message("features.argo.missing_file_error")) unless File.exist?(filepath)

        renderer_version = nil
        if include_renderer_version
          renderer_version = renderer_package(context).version
        end

        begin
          {
            renderer_version: renderer_version,
            serialized_script: Base64.strict_encode64(File.read(filepath).chomp),
          }
        rescue StandardError
          context.abort(context.message("features.argo.script_prepare_error"))
        end
      end

      def renderer_package(context)
        Tasks::FindPackageFromJson.call(renderer_package_name, context: context)
      end
    end
  end
end
