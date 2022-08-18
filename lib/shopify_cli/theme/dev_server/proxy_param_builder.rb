# frozen_string_literal: true

require "cgi"

module ShopifyCLI
  module Theme
    class DevServer
      class ProxyParamBuilder
        def build
          # Core doesn't support replace_templates
          return {} if core?(current_path)

          (syncer_templates + request_templates)
            .select { |file| file.liquid? || file.json? }
            .uniq(&:relative_path)
            .map { |file| as_param(file) }
            .to_h
        end

        def with_core_endpoints(core_endpoints)
          @core_endpoints = core_endpoints
          self
        end

        def with_syncer(syncer)
          @syncer = syncer
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
          ["replace_templates[#{file.relative_path}]", file.read]
        end

        def syncer_templates
          @syncer&.pending_updates || []
        end

        def request_templates
          cookie_sections
            .map { |section| @theme[section] unless @theme.nil? }
            .compact
        end

        def cookie_sections
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
