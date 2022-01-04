# typed: ignore
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Forms
    module Questions
      class AskTypeTest < MiniTest::Test
        include TestHelpers
        include ExtensionTestHelpers

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_returns_if_the_given_extension_type_valid
          ask(type: "TEST_EXTENSION").tap do |result|
            assert_predicate(result, :success?)
            result.value.tap do |project_details|
              refute_nil project_details.type
              assert_kind_of(TestExtension, project_details.type)
            end
          end
        end

        def test_aborts_if_the_given_extension_type_is_invalid
          ask(type: "INVALID_EXTENSION_IDENTIFIER").tap do |result|
            assert_predicate(result, :failure?)
            result.error.tap do |error|
              assert_kind_of(CLI::Kit::Abort, error)
            end
          end
        end

        def test_prompts_user_to_choose_extension_type_if_no_type_was_given
          prompt = PromptToChooseOption.new
          ask(prompt: prompt).tap do |result|
            assert_predicate(result, :success?)
            result.value.tap do |project_details|
              refute_nil project_details.type
              assert_kind_of(TestExtension, project_details.type)
            end
          end

          assert_equal 1, prompt.options.count
        end

        def test_aborts_if_server_does_not_return_any_specifications
          specifications = Models::Specifications.new(fetch_specifications: -> { [] })
          Models::Specifications.expects(:new).returns(specifications)
          project_details = OpenStruct.new(app: Models::App.new(api_key: "1234", secret: "0000"))
          context = FakeContext.new
          context.expects(:puts).with(context.message("create.no_available_extensions"))

          AskType.new(ctx: context).call(project_details).tap do |result|
            assert_predicate(result, :failure?)
            result.error.tap do |error|
              assert_kind_of(ShopifyCLI::AbortSilent, error)
            end
          end
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

        private

        def ask(**options)
          specifications = DummySpecifications.build(
            custom_handler_root: File.expand_path("../../", __FILE__),
            custom_handler_namespace: ::Extension::ExtensionTestHelpers,
          )
          Models::Specifications.expects(:new).returns(specifications)
          project_details = OpenStruct.new(app: Models::App.new(api_key: "1234", secret: "0000"))
          AskType.new(ctx: FakeContext.new, **options).call(project_details)
        end
      end
    end
  end
end
