# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/forms/apply_to_all_form"

module ShopifyCLI
  module Theme
    class Syncer
      module Forms
        class ApplyToAllFormTest < Minitest::Test
          def test_ask
            @context
              .expects(:message)
              .with("theme.serve.syncer.forms.apply_to_all.title", 4)
              .returns("title")

            CLI::UI::Prompt
              .expects(:ask)
              .with("title", allow_empty: false)
              .returns(true)

            assert ApplyToAllForm.ask(@context, [], number_of_files: 5)
          end
        end
      end
    end
  end
end
