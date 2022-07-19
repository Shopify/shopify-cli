# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server/proxy/app_extension_template_param_builder"

module ShopifyCLI
  module Theme
    module DevServer
      class BaseProxy
        class AppExtensionTemplateParamBuilderTest < Minitest::Test
          def setup
            super
            @param_builder = AppExtensionTemplateParamBuilder.new
          end

          def test_empty_build
            assert_equal({}, @param_builder.build)
          end

          def test_build_with_rack_env
            @param_builder
              .with_theme(theme)
              .with_rack_env({ "HTTP_COOKIE" => http_cookie })

            assert_equal({
              "replace_extension_templates[blocks][blocks/block.liquid]" => "<block file content>",
              "replace_extension_templates[snippets][snippets/snippet.liquid]" => "<snippet file content>",
            }, @param_builder.build)
          end

          def test_build_with_rack_env_with_json
            @param_builder
              .with_theme(theme)
              .with_rack_env({
                "HTTP_COOKIE" => http_cookie("blocks/block.liquid,snippets/snippet.liquid,locales/fr.json"),
              })

            assert_equal({
              "replace_extension_templates[blocks][blocks/block.liquid]" => "<block file content>",
              "replace_extension_templates[snippets][snippets/snippet.liquid]" => "<snippet file content>",
              "replace_extension_templates[locales/fr.json]" => "{ json file }",
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

          def test_build_when_rack_env_is_empty
            @param_builder.with_rack_env({})

            assert_equal({}, @param_builder.build)
          end

          private

          def theme
            block = liquid_block_file("block")
            snippet = liquid_snippet_file("snippet")
            locales = json_file("fr")

            {
              block.relative_path => block,
              snippet.relative_path => snippet,
              locales.relative_path => locales,
            }
          end

          def liquid_block_file(name)
            stub(
              "read": "<#{name} file content>",
              "relative_path": "blocks/#{name}.liquid",
              "liquid?": true,
              "json?": false
            )
          end

          def liquid_snippet_file(name)
            stub(
              "read": "<#{name} file content>",
              "relative_path": "snippets/#{name}.liquid",
              "liquid?": true,
              "json?": false
            )
          end

          def json_file(name)
            stub(
              "read": "{ json file }",
              "relative_path": "locales/#{name}.json",
              "liquid?": false,
              "json?": true
            )
          end

          def http_cookie(hot_reload_files = "blocks/block.liquid,snippets/snippet.liquid")
            "cart_currency=EUR; storefront_digest=123; hot_reload_sections=#{hot_reload_files}"
          end
        end
      end
    end
  end
end
