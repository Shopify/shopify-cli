# frozen_string_literal: true

require "cgi"

module ShopifyCLI
  module Theme
    module Extension
      module DevServer
        class ProxyParamBuilder
          def build
            # Core doesn't support replace_extension_templates
            return {} if core?(current_path)

            request_templates
              .select(&:liquid?)
              .uniq(&:relative_path)
              .map { |file| as_param(file) }
              .to_h
          end

          def with_core_endpoints(core_endpoints)
            @core_endpoints = core_endpoints
            self
          end

          def with_rack_env(rack_env)
            @rack_env = rack_env
            self
          end

          def with_extension(extension)
            @extension = extension
            self
          end

          private

          def as_param(file)
            if file&.relative_path&.include?("blocks/")
              ["replace_extension_templates[blocks][#{file.relative_path}]", file.read]
            elsif file&.relative_path&.include?("snippets/")
              ["replace_extension_templates[snippets][#{file.relative_path}]", file.read]
            end
          end

          def request_templates
            cookie_files
              .map { |file_path| @extension[file_path] unless @extension.nil? }
              .compact
          end

          def cookie_files
            CGI::Cookie.parse(cookie)["hot_reload_files"].join.split(",") || []
          end

          def core?(path)
            core_endpoints.include?(path)
          end

          def current_path
            rack_env["PATH_INFO"]
          end

          def cookie
            rack_env["HTTP_COOKIE"]
          end

          def core_endpoints
            @core_endpoints || []
          end

          def rack_env
            @rack_env || {}
          end
        end
      end
    end
  end
end
