# frozen_string_literal: true

require "cgi"

module ShopifyCLI
  module Theme
    module DevServer
      class BaseProxy
        class AppExtensionTemplateParamBuilder
          def build
            # Core doesn't support replace_extension_templates
            return {} if core?(current_path)

            request_templates
              .select { |file| file.liquid? || file.json? }
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

          def with_theme(theme)
            @theme = theme
            self
          end

          private

          def as_param(file)
            if file&.relative_path&.include? "blocks/"
              ["replace_extension_templates[blocks][#{file.relative_path}]", file.read]
            elsif file&.relative_path&.include? "snippets/"
              ["replace_extension_templates[snippets][#{file.relative_path}]", file.read]
            end
          end

          def request_templates
            # TODO assuming "section" is referring to section id, this should work for app embed
            # blocks too? or will "hot_reload_sections" not include app embed blocks?
            cookie_sections
              .map { |section| @theme[section] unless @theme.nil? }
              .compact
          end

          def cookie_sections
            CGI::Cookie.parse(cookie)["hot_reload_sections"].join.split(",") || []
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
