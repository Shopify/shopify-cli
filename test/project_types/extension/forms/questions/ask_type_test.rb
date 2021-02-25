require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Forms
    module Questions
      class AskNameTest < MiniTest::Test
        include TestHelpers
        include TestHelpers::FakeUI
        include ExtensionTestHelpers

        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)

          @original_specifications = Extension.specifications
          Extension.specifications = Models::Specifications.new(
            custom_handler_root: File.expand_path("../../", __FILE__),
            custom_handler_namespace: ::Extension::ExtensionTestHelpers,
            fetch_specifications: -> { [{ identifier: "test_extension" }] }
          )
        end

        def teardown
          Extension.specifications = @original_specifications
        end

        def test_returns_if_the_given_extension_type_valid
          identifier = "TEST_EXTENSION"
          AskType.new(ctx: FakeContext.new, type: identifier).call(OpenStruct.new({})).tap do |result|
            assert_predicate(result, :success?)
            result.value.tap do |project_details|
              refute_nil project_details.type
              assert_kind_of(TestExtension, project_details.type)
            end
          end
        end

        def test_aborts_if_the_given_extension_type_is_invalid
          identifier = "INVALID_EXTENSION_IDENTIFIER"
          AskType.new(ctx: FakeContext.new, type: identifier).call(OpenStruct.new({})).tap do |result|
            assert_predicate(result, :failure?)
            result.error.tap do |error|
              assert_kind_of(CLI::Kit::Abort, error)
            end
          end
        end

        def test_prompts_user_to_choose_extension_type_if_no_type_was_given
          prompt = PromptToChooseOption.new

          AskType.new(ctx: FakeContext.new, prompt: prompt).call(OpenStruct.new).tap do |result|
            assert_predicate(result, :success?)
            result.value.tap do |project_details|
              refute_nil project_details.type
              assert_kind_of(TestExtension, project_details.type)
            end
          end

          assert_equal 1, prompt.options.count
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
