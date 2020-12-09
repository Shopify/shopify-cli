# frozen_string_literal: true
require 'base64'
require 'shopify_cli'
require 'semantic/semantic'

module Extension
  module Features
    module Argo
      class Base
        include SmartProperties

        SCRIPT_PATH = %w[build main.js].freeze

        NPM_LIST_COMMAND = %w[list].freeze
        YARN_LIST_COMMAND = %w[list --pattern].freeze
        NPM_LIST_PARAMETERS = %w[--prod].freeze
        YARN_LIST_PARAMETERS = %w[--production].freeze
        private_constant :NPM_LIST_COMMAND, :YARN_LIST_COMMAND, :NPM_LIST_PARAMETERS, :YARN_LIST_PARAMETERS

        YARN_INSTALL_COMMAND = %w[install].freeze
        YARN_INSTALL_PARAMETERS = %w[--silent].freeze
        YARN_RUN_COMMAND = %w[run].freeze
        YARN_RUN_SCRIPT_NAME = %w[build].freeze
        private_constant :YARN_INSTALL_COMMAND, :YARN_INSTALL_PARAMETERS, :YARN_RUN_COMMAND, :YARN_RUN_SCRIPT_NAME

        def create(directory_name, identifier, context)
          Features::ArgoSetup.new(git_template: git_template).call(directory_name, identifier, context)
        end

        def config(context)
          js_system = ShopifyCli::JsSystem.new(ctx: context)
          if js_system.package_manager == 'yarn'
            run_yarn_install(context, js_system)
            run_yarn_run_script(context, js_system)
          end
          filepath = File.join(context.root, SCRIPT_PATH)
          context.abort(context.message('features.argo.missing_file_error')) unless File.exist?(filepath)
          begin
            {
              renderer_version: extract_argo_renderer_version(context),
              serialized_script: Base64.strict_encode64(File.read(filepath).chomp),
            }
          rescue StandardError
            context.abort(context.message('features.argo.script_prepare_error'))
          end
        end

        def git_template
          raise NotImplementedError, "'#{__method__}' must be implemented for #{self.class}"
        end

        def renderer_package_name
          # The renderer_package_name is used as a regex pattern to
          # find a match in the output of yarn or npm list command.
          # Use the full package name as it appears in the template without targeting a version.
          # Examples: "@shopify/some-renderer-package", "argo-renderer-package"

          raise NotImplementedError, "'#{__method__}' must be implemented for #{self.class}"
        end

        private

        def extract_argo_renderer_version(context)
          result = run_list_command(context)
          found_version = find_version_number(context, result)
          if found_version.nil?
            context.abort(context.message('features.argo.dependencies.argo_renderer_package_invalid_version_error'))
          end
          ::Semantic::Version.new(found_version).to_s
        rescue ArgumentError
          context.abort(context.message('features.argo.dependencies.argo_renderer_package_invalid_version_error'))
        end

        def find_version_number(context, result)
          packages = result.to_json.split('\n')
          found_package = packages.find { |package| package.match(/#{renderer_package_name}@/) }
          if found_package.nil?
            error = "'#{renderer_package_name}' not found."
            context.abort(context.message('features.argo.dependencies.argo_missing_renderer_package_error', error))
          end
          found_package.split('@')[2]&.strip
        end

        def run_list_command(context)
          js_system = ShopifyCli::JsSystem.new(ctx: context)
          result, error, status =
            js_system.call(
              yarn: YARN_LIST_COMMAND + [renderer_package_name] + YARN_LIST_PARAMETERS,
              npm: NPM_LIST_COMMAND + [renderer_package_name] + NPM_LIST_PARAMETERS,
              capture_response: true,
            )
          unless status.success?
            context.abort(context.message('features.argo.dependencies.argo_missing_renderer_package_error', error))
          end
          result
        end

        def run_yarn_install(context, js_system)
          _result, error, status =
            js_system.call(yarn: YARN_INSTALL_COMMAND + YARN_INSTALL_PARAMETERS, npm: [], capture_response: true)

          context.abort(context.message('features.argo.dependencies.yarn_install_error', error)) unless status.success?
        end

        def run_yarn_run_script(context, js_system)
          _result, error, status =
            js_system.call(yarn: YARN_RUN_COMMAND + YARN_RUN_SCRIPT_NAME, npm: [], capture_response: true)

          unless status.success?
            context.abort(context.message('features.argo.dependencies.yarn_run_script_error', error))
          end
        end
      end
    end
  end
end
