# frozen_string_literal: true

require "test_helper"
require "timecop"
require "shopify_cli/theme/syncer/unsupported_script_warning"

module ShopifyCLI
  module Theme
    class Syncer
      class UnsupportedScriptWarningTest < Minitest::Test
        def setup
          super
          Context.stubs(:messages).returns(messages_mock)

          file = stub(
            read: [
              "http://123.com",
              "http://456.com",
              "http://789.com",
            ].join("\n "),
            warnings: [
              { "line" => 1, "column" => 1 },
              { "line" => 3, "column" => 2 },
            ]
          )
          @warning = UnsupportedScriptWarning.new(@context, file)
        end

        def test_to_s
          actual_message = @warning.to_s

          assert_equal(<<~EXPECTED_MESSAGE, actual_message)


          {{blue: 1 |}} http://123.com
          {{yellow:     ^ {{bold:unsupported script}}}}

          {{blue: 3 |}}  http://789.com
          {{yellow:      ^ {{bold:unsupported script}}}}
           {{yellow: unsupported script long text, lines:line 1 and column 1line 3 and column 2}}
          EXPECTED_MESSAGE
        end

        private

        def messages_mock
          {
            theme: {
              serve: {
                syncer: {
                  warnings: {
                    unsupported_script: "unsupported script",
                    unsupported_script_text: "unsupported script long text, lines:%s",
                    line_and_column: "line %s and column %s",
                  },
                },
              },
            },
          }
        end
      end
    end
  end
end
