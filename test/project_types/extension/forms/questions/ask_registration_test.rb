# typed: ignore
# frozen_string_literal: true

require "test_helper"

module Extension
  module Forms
    module Questions
      class AskRegistrationTest < MiniTest::Test
        include TestHelpers

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
          @ask_registration = AskRegistration.new(ctx: @context, type: "THEME_APP_EXTENSION")
        end

        def test_load_registrations
          stubs_get_extensions
          project_details = OpenStruct.new

          io = capture_io { @ask_registration.call(project_details) }.join

          assert_includes io, "✓"
          assert_includes io, "Loading your extensions…"
        end

        private

        def stubs_get_extensions
          Tasks::GetExtensions
            .any_instance
            .expects(:call)
            .returns([OpenStruct.new])
        end
      end
    end
  end
end
