require "test_helper"
require "securerandom"

module ShopifyCLI
  class LazyDelegatorTest < MiniTest::Test
    def test_defers_invocation_of_the_provided_block_until_absolutely_necessary
      person_created = false

      person = LazyDelegator.new do
        person_created = true
        create_person
      end

      refute person_created
      person.firstname
      assert person_created
    end

    def test_delegates_method_calls_to_the_return_value_of_the_provided_block
      person = LazyDelegator.new { create_person(firstname: "Jane") }
      assert_equal "Jane", person.firstname
    end

    def test_memoizes_the_return_value_of_the_provided_block
      person = LazyDelegator.new { create_person(firstname: "Jane") }
      assert_equal person.id, person.id
    end

    private

    def create_person(firstname: "John", lastname: "Doe")
      OpenStruct.new(firstname: firstname, lastname: lastname, id: SecureRandom.uuid)
    end
  end
end
