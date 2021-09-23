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

      def config(context)
        js_system = ShopifyCLI::JsSystem.new(ctx: context)
        if js_system.package_manager == "yarn"
          run_yarn_install(context, js_system)
          run_yarn_run_script(context, js_system)
        end
        filepath = File.join(context.root, SCRIPT_PATH)
        context.abort(context.message("features.argo.missing_file_error")) unless File.exist?(filepath)
        begin
          {
            renderer_version: renderer_package(context).version,
            serialized_script: Base64.strict_encode64(File.read(filepath).chomp),
          }
        rescue StandardError
          context.abort(context.message("features.argo.script_prepare_error"))
        end
      end

      def renderer_package(context)
        js_system = ShopifyCLI::JsSystem.new(ctx: context)
        Tasks::FindNpmPackages
          .exactly_one_of(renderer_package_name, js_system: js_system, production_only: true)
          .unwrap { |err| raise err }
      rescue Extension::PackageResolutionFailed
        context.abort(
          context.message("features.argo.dependencies.argo_missing_renderer_package_error")
        )
      end

      private

      def run_yarn_install(context, js_system)
        _result, error, status = js_system.call(
          yarn: YARN_INSTALL_COMMAND + YARN_INSTALL_PARAMETERS,
          npm: [],
          capture_response: true
        )

        context.abort(
          context.message("features.argo.dependencies.yarn_install_error", error)
        ) unless status.success?
      end

      def run_yarn_run_script(context, js_system)
        _result, error, status = js_system.call(
          yarn: YARN_RUN_COMMAND + YARN_RUN_SCRIPT_NAME,
          npm: [],
          capture_response: true
        )

        context.abort(
          context.message("features.argo.dependencies.yarn_run_script_error", error)
        ) unless status.success?
      end
    end
  end
end
