# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoConfigTest < MiniTest::Test
      def setup
        super
        File.stubs(:size?).returns(true)
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_parses_and_symbolizes_yaml_hash
        value = {}
        another_value = 10
        yml = { "value": value, "another_value": another_value }
        YAML.stubs(:load_file).returns(yml)

        parsed_config = ArgoConfig.parse_yaml(@context, [:value, :another_value])

        assert_equal(value, parsed_config[:value])
        assert_equal(another_value, parsed_config[:another_value])
      end

      def test_aborts_when_yaml_is_invalid
        YAML.stubs(:load_file).raises(Psych::SyntaxError.new(nil, 1, 1, nil, nil, nil))
        assert_raises(ShopifyCLI::Abort) { ArgoConfig.parse_yaml(@context) }
      end

      def test_aborts_when_yaml_is_not_a_hash
        YAML.stubs(:load_file).returns(false)

        assert_raises(ShopifyCLI::Abort) { ArgoConfig.parse_yaml(@context) }
      end

      def test_returns_empty_hash_when_file_not_found_or_empty
        File.stubs(:size?).returns(false)

        assert_equal({}, ArgoConfig.parse_yaml(@context))
      end

      def test_returns_empty_hash_when_file_contains_no_parsable_yaml_data
        YAML.stubs(:load_file).returns(nil)

        assert_equal({}, ArgoConfig.parse_yaml(@context))
      end

      def test_aborts_when_yaml_contains_unpermitted_keys
        permitted_keys = [:a, :b]

        YAML.stubs(:load_file).returns({ "a" => 1, "c" => 1 })

        assert_raises(ShopifyCLI::Abort) { ArgoConfig.parse_yaml(@context, permitted_keys) }
      end

      def test_does_not_abort_when_yaml_contains_no_unpermitted_keys
        permitted_keys = [:a, :b]

        YAML.stubs(:load_file).returns({ "a" => 1, "b" => 1 })

        assert_nothing_raised(ShopifyCLI::Abort) { ArgoConfig.parse_yaml(@context, permitted_keys) }
      end
    end
  end
end
