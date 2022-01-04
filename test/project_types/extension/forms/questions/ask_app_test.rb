# typed: ignore
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Forms
    module Questions
      class AskAppTest < MiniTest::Test
        include TestHelpers
        include ExtensionTestHelpers::Stubs::GetApp
        include ExtensionTestHelpers::Stubs::GetOrganizations

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_setup
          assert true
        end

        def test_accepts_a_valid_api_key
          app = Models::App.new(title: "Fake", api_key: "1234", secret: "4567")
          stub_get_app(api_key: "1234", app: app)
          AskApp.new(ctx: FakeContext.new, api_key: "1234").call(OpenStruct.new).tap do |result|
            assert_predicate(result, :success?)
            result.value.app.tap do |returned_app|
              assert_equal app.title, returned_app.title
              assert_equal app.api_key, returned_app.api_key
              assert_equal app.secret, returned_app.secret
            end
          end
        end

        def test_aborts_when_invalid_api_key_is_provided
          api_key = "1234"
          stub_get_app(api_key: api_key, app: nil)

          AskApp.new(ctx: @context, api_key: api_key).call(OpenStruct.new).tap do |result|
            assert_predicate(result, :failure?)
            result.error.tap do |error|
              assert_kind_of(ShopifyCLI::Abort, error)
              assert_match(@context.message("create.invalid_api_key", api_key), error.message)
            end
          end
        end

        def test_fetches_all_apps_if_no_api_key_was_given
          apps = [
            Models::App.new(title: "Fake 1", api_key: "1234", secret: "4567"),
            Models::App.new(title: "Fake 2", api_key: "abcd", secret: "efgh"),
          ]
          stub_get_organizations([
            organization(name: "Organization One", apps: apps),
          ])

          prompt = PromptToChooseOption.new
          AskApp.new(ctx: FakeContext.new, prompt: prompt).call(OpenStruct.new).tap do |result|
            assert_predicate(result, :success?)
            result.value.app.tap do |app|
              assert_kind_of(Models::App, app)
            end
          end

          assert_equal 2, prompt.options.count
        end

        def test_aborts_and_informs_user_if_there_are_no_apps
          stub_get_organizations([
            organization(name: "Organization One", apps: []),
          ])

          io = capture_io do
            AskApp.new(ctx: @context, prompt: ->(_) {}).call(OpenStruct.new).tap do |result|
              assert_predicate(result, :failure?)
              assert_kind_of(ShopifyCLI::AbortSilent, result.error)
            end
          end

          assert_message_output(io: io, expected_content: [
            @context.message("create.no_apps"),
            @context.message("create.learn_about_apps"),
          ])
        end

        class PromptToChooseOption
          Option = Struct.new(:message, :value)

          attr_reader :options

          def initialize
            @options = []
          end

          def option(message, &block)
            @options.push(Option.new(message, block.call))
          end

          def to_proc
            ->(handler, _message, &configure) {
              configure.call(handler)
              handler.options.sample.value
            }.curry[self]
          end
        end
      end
    end
  end
end
