# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server/proxy/template_param_builder"

module ShopifyCLI
  module Theme
    module DevServer
      class Proxy
        class TemplateParamBuilderTest < Minitest::Test
          def setup
            super
            @param_builder = TemplateParamBuilder.new
          end

          def test_empty_build
            assert_equal({}, @param_builder.build)
          end

          def test_build_with_syncer_and_rack_env
            @param_builder
              .with_syncer(syncer)
              .with_theme(theme)
              .with_rack_env({ "HTTP_COOKIE" => http_cookie })

            assert_equal({
              "replace_templates[layout/theme.liquid]" => "<theme file content>",
              "replace_templates[layout/password.liquid]" => "<password file content>",
              "replace_templates[layout/config.json.json]" => "{ json file }",
            }, @param_builder.build)
          end

          def test_build_with_syncer
            @param_builder
              .with_syncer(syncer)

            assert_equal({
              "replace_templates[layout/theme.liquid]" => "<theme file content>",
              "replace_templates[layout/password.liquid]" => "<password file content>",
              "replace_templates[layout/config.json.json]" => "{ json file }",
            }, @param_builder.build)
          end

          def test_build_with_rack_env
            @param_builder
              .with_theme(theme)
              .with_rack_env({ "HTTP_COOKIE" => http_cookie })

            assert_equal({
              "replace_templates[layout/theme.liquid]" => "<theme file content>",
            }, @param_builder.build)
          end

          def test_build_with_rack_env_when_current_path_is_a_core_endpoint
            @param_builder
              .with_theme(theme)
              .with_core_endpoints(["/core_end_point"])
              .with_rack_env({
                "HTTP_COOKIE" => http_cookie,
                "PATH_INFO" => "/core_end_point",
              })

            assert_equal({}, @param_builder.build)
          end

          def test_build_with_rack_env_when_theme_is_nil
            @param_builder
              .with_rack_env({ "HTTP_COOKIE" => http_cookie })

            assert_equal({}, @param_builder.build)
          end

          def test_build_when_rack_env_is_empty
            @param_builder.with_rack_env({})

            assert_equal({}, @param_builder.build)
          end

          private

          def theme
            stub("[]": liquid_file("theme"))
          end

          def liquid_file(name)
            stub(
              "read": "<#{name} file content>",
              "relative_path": "layout/#{name}.liquid",
              "liquid?": true,
              "json?": false
            )
          end

          def json_file(name)
            stub(
              "read": "{ json file }",
              "relative_path": "layout/#{name}.json",
              "liquid?": false,
              "json?": true
            )
          end

          def http_cookie
            "cart_currency=EUR; storefront_digest=123; hot_reload_sections=layout/theme.liquid"
          end

          def syncer
            @syncer ||= stub("pending_updates": [
              liquid_file("theme"),
              liquid_file("password"),
              json_file("config.json"),
              stub(
                "relative_path": ".gitignore",
                "liquid?": false,
                "json?": false
              ),
            ])
          end
        end
      end
    end
  end
end
