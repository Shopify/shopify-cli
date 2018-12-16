require 'test_helper'

module CLI
  module Kit
    class AutocallTest < MiniTest::Test
      def test_autocall
        mod = Module.new do
          extend Autocall
          autocall(:Foo) { 42 }
          autocall(:Bar) { rand }
        end
        # base case works
        assert_equal(42, mod::Foo)

        # Only evaluates once
        assert_equal(mod::Bar, mod::Bar)

        # Fails on missing
        assert_raises(NameError) { mod::Baz }
      end
    end
  end
end
