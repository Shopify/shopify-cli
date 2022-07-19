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

          def test_build_with_syncer_and_rack_env
            @param_builder
              .with_theme(theme)
              .with_rack_env({ "HTTP_COOKIE" => http_cookie })

            #   ["replace_extension_templates[blocks][#{file.relative_path}]", file.read]
            # elsif file&.relative_path&.include? "snippets/"
            #   ["replace_extension_templates[snippets][#{file.relative_path}]", file.read]
            # end

            assert_equal({
              "replace_extension_templates[blocks][blocks/block.liquid]" => "<block file content>",
              # "replace_extension_templates[snippets][snippets/snippet.liquid]" => "<theme file content>",
            }, @param_builder.build)
          end

          private

          def theme
            stub("[]": liquid_file("block"))
          end

          def liquid_file(name)
            stub(
              "read": "<#{name} file content>",
              "relative_path": "blocks/#{name}.liquid",
              "liquid?": true,
              "json?": false
            )
          end

          def http_cookie
            "cart_currency=EUR; storefront_digest=123; hot_reload_sections=blocks/block.liquid"
          end
        end
      end
    end
  end
end
