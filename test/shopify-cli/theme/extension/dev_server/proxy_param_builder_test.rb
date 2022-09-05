# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/extension/dev_server/proxy_param_builder"

module ShopifyCLI
  module Theme
    module Extension
      class DevServer
        class ProxyParamBuilderTest < Minitest::Test
          def setup
            super
            @param_builder = ProxyParamBuilder.new
            @syncer = stub(pending_updates: [])
          end

          def test_empty_build
            assert_equal({}, @param_builder.build)
          end

          def test_build_with_syncer
            @param_builder
              .with_syncer(@syncer)

            @syncer.expects(:pending_updates).returns([
              extension["blocks/block.liquid"],
              extension["snippets/snippet.liquid"],
            ])

            assert_equal({
              "replace_extension_templates[blocks][blocks/block.liquid]" => "<block file content>",
              "replace_extension_templates[snippets][snippets/snippet.liquid]" => "<snippet file content>",
            }, @param_builder.build)
          end

          def test_build_with_rack_env
            @param_builder
              .with_extension(extension)
              .with_rack_env({ "HTTP_COOKIE" => http_cookie })
              .with_syncer(@syncer)

            assert_equal({
              "replace_extension_templates[blocks][blocks/block.liquid]" => "<block file content>",
              "replace_extension_templates[snippets][snippets/snippet.liquid]" => "<snippet file content>",
            }, @param_builder.build)
          end

          def test_build_with_rack_env_when_current_path_is_a_core_endpoint
            @param_builder
              .with_extension(extension)
              .with_core_endpoints(["/core_end_point"])
              .with_rack_env({
                "HTTP_COOKIE" => http_cookie,
                "PATH_INFO" => "/core_end_point",
              })
              .with_syncer(@syncer)

            assert_equal({}, @param_builder.build)
          end

          def test_build_when_rack_env_is_empty
            @param_builder.with_rack_env({})

            assert_equal({}, @param_builder.build)
          end

          private

          def extension
            block = liquid_block_file("block")
            snippet = liquid_snippet_file("snippet")
            # add json to be sure tests ignore these files
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
            "cart_currency=EUR; storefront_digest=123; hot_reload_files=#{hot_reload_files}"
          end
        end
      end
    end
  end
end
