# typed: ignore
require "test_helper"

module ShopifyCLI
  class MethodObjectTest < Minitest::Test
    class GenerateHelloWorld
      include ShopifyCLI::MethodObject

      def call(*)
        "Hello World"
      end
    end

    class GenerateNumber
      include ShopifyCLI::MethodObject

      property :range, accepts: Range

      def call(*)
        rand(range)
      end
    end

    class Upcase
      include ShopifyCLI::MethodObject

      def call(string)
        string.upcase
      end
    end

    class ToJson
      include ShopifyCLI::MethodObject

      def call(**data)
        data.to_json
      end
    end

    class BuildArray
      include ShopifyCLI::MethodObject

      def call(*elements)
        elements
      end
    end

    class TransformArray
      include ShopifyCLI::MethodObject

      def call(*elements, &transform)
        elements.map(&transform)
      end
    end

    def test_returns_a_result
      GenerateHelloWorld.new.call.tap do |result|
        assert_kind_of(ShopifyCLI::Result::Success, result)
        assert_equal "Hello World", result.value
      end
    end

    def test_chain_of_method_object
      GenerateHelloWorld
        .call
        .then(&Upcase)
        .tap do |result|
          assert result.success?
          assert_equal "HELLO WORLD", result.value
        end
    end

    def test_handles_errors_gracefully
      GenerateNumber
        .call
        .then(&Upcase)
        .tap do |result|
          assert result.failure?
          assert_kind_of(NoMethodError, result.unwrap { |err| err })
        end
    end

    def test_support_configuration_options
      assert_includes 1..10, GenerateNumber.call(range: 1..10).value
    end

    def test_forwards_all_keyword_arguments_that_are_not_configuration_options_to_call
      ToJson
        .call(firstname: "John", lastname: "Doe")
        .map { |json| JSON.parse(json) }
        .map { |hash| OpenStruct.new(hash) }
        .tap do |result|
          assert result.success?

          result.value.tap do |person|
            assert_equal "John", person.firstname
            assert_equal "Doe", person.lastname
          end
        end
    end

    def test_does_not_forward_an_empty_list_of_keword_arguments_to_call
      BuildArray
        .call("Hello", "World")
        .tap do |result|
          assert_predicate(result, :success?)
          assert_equal ["Hello", "World"], result.value
        end
    end

    def test_forwards_blocks_to_call
      TransformArray
        .call("Hello", "World", &:upcase)
        .tap do |result|
          assert_predicate(result, :success?)
          assert_equal %w[HELLO WORLD], result.value
        end
    end
  end
end
