require "test_helper"

module ShopifyCli
  class MethodObjectTest < Minitest::Test
    class GenerateHelloWorld
      include ShopifyCli::MethodObject

      def call(*)
        "Hello World"
      end
    end

    class GenerateNumber
      include ShopifyCli::MethodObject

      property :range, accepts: Range

      def call(*)
        rand(range)
      end
    end

    class Upcase
      include ShopifyCli::MethodObject

      def call(string)
        string.upcase
      end
    end

    class ToJson
      include ShopifyCli::MethodObject

      def call(**data)
        data.to_json
      end
    end

    def test_returns_a_result
      GenerateHelloWorld.new.call.tap do |result|
        assert_kind_of(ShopifyCli::Result::Success, result)
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
  end
end
