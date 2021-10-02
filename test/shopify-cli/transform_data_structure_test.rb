require "test_helper"

module ShopifyCLI
  class TransformDataStructureTest < MiniTest::Test
    def test_primitive_values_are_returned_as_is
      [true, false, 1, "hello", :hello].each do |value|
        TransformDataStructure.call(value).tap do |result|
          assert_predicate(result, :success?)
          assert_equal(value, result.value)
        end
      end

      TransformDataStructure.call(nil).tap do |result|
        assert_predicate(result, :success?)
        assert_nil(result.value)
      end
    end

    def test_deep_symbolize_keys_of_flat_structure
      TransformDataStructure.new(symbolize_keys: true).call({ "a" => 1, "b" => 2 }).tap do |result|
        assert_predicate(result, :success?)
        assert_equal({ a: 1, b: 2 }, result.value)
      end
    end

    def test_deep_symbolize_keys_of_hash_in_array
      TransformDataStructure.new(symbolize_keys: true).call([{ "a" => 1, "b" => 2 }]).tap do |result|
        assert_predicate(result, :success?)
        assert_equal([{ a: 1, b: 2 }], result.value)
      end
    end

    def test_symbolizing_the_keys_of_a_deeply_nested_data_structure
      given_input = { "Nodes" => [{ "ID" => 1, "Active" => true }] }
      expected_output = { Nodes: [{ ID: 1, Active: true }] }
      TransformDataStructure
        .new(symbolize_keys: true)
        .call(given_input).tap do |result|
          assert_predicate(result, :success?)
          assert_equal(expected_output, result.value)
        end
    end

    def test_snake_case_conversion_with_symbolization
      given_input = {
        "MessageId" => 1,
        "TTL" => 3600,
        "useTLS" => true,
        "Message-Priority" => "high",
        "Transport Protocol" => "tcp",
      }

      expected_output = {
        message_id: 1,
        ttl: 3600,
        use_tls: true,
        message_priority: "high",
        transport_protocol: "tcp",
      }

      TransformDataStructure
        .new(symbolize_keys: true, underscore_keys: true)
        .call(given_input).tap do |result|
          assert_predicate(result, :success?)
          assert_equal(expected_output, result.value)
        end
    end

    def test_snake_case_conversation_without_symbolzation
      given_input = { "MessageId" => 1 }
      expected_output = { "message_id" => 1 }

      TransformDataStructure
        .new(underscore_keys: true)
        .call(given_input).tap do |result|
          assert_predicate(result, :success?)
          assert_equal(expected_output, result.value)
        end
    end

    def test_underscore_keys_works_with_already_underscored_keys
      given_input = { "message_id" => 1 }
      expected_output = given_input

      TransformDataStructure
        .new(underscore_keys: true)
        .call(given_input).tap do |result|
          assert_predicate(result, :success?)
          assert_equal(expected_output, result.value)
        end
    end

    def test_replacing_hashes_with_another_associative_array_container
      TransformDataStructure.new(associative_array_container: OpenStruct).call({ a: 1 }).tap do |result|
        assert_predicate(result, :success?)
        assert_kind_of(OpenStruct, result.value)
        assert_equal(1, result.value.a)
      end
    end
  end
end
