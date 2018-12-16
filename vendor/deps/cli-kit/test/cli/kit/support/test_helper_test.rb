require 'test_helper'

module CLI
  module Kit
    module Support
      class TestHelperTest < MiniTest::Test
        include CLI::Kit::Support::TestHelper

        def test_when_all_commands_not_run
          CLI::Kit::System.fake('banana', success: true)

          errors = assert_all_commands_run(should_raise: false)
          expected_err = <<~EOF

          Expected commands were not run:
          banana
          EOF
          assert_equal expected_err, CLI::UI::ANSI.strip_codes(errors)
        end

        def test_when_unexpected_command
          CLI::Kit::System.system('banana')

          errors = assert_all_commands_run(should_raise: false)
          expected_err = <<~EOF

          Unexpected command invocations:
          banana
          EOF
          assert_equal expected_err, CLI::UI::ANSI.strip_codes(errors)
        end

        def test_when_commands_not_run_correctly
          CLI::Kit::System.fake('banana', success: true)
          CLI::Kit::System.fake('kiwi', success: true)

          CLI::Kit::System.system('banana', sudo: true, env: { kiwi: false })
          CLI::Kit::System.system('kiwi', sudo: true, env: { kiwi: false })

          errors = assert_all_commands_run(should_raise: false)
          expected_err = <<~EOF

          Commands were not run as expected:
          banana
          - sudo was supposed to be false but was true
          - env was supposed to be {} but was {:kiwi=>false}

          kiwi
          - sudo was supposed to be false but was true
          - env was supposed to be {} but was {:kiwi=>false}
          EOF
          assert_equal expected_err, CLI::UI::ANSI.strip_codes(errors)
        end

        def test_all_captures_and_system
          CLI::Kit::System.fake('banana', success: true)
          CLI::Kit::System.fake('kiwi', success: true)
          CLI::Kit::System.fake('apple', success: true)
          CLI::Kit::System.fake('orange', success: true)

          CLI::Kit::System.system('banana').success?
          CLI::Kit::System.capture2('kiwi').last.success?
          CLI::Kit::System.capture2e('apple').last.success?
          CLI::Kit::System.capture3('orange').last.success?

          errors = assert_all_commands_run(should_raise: false)
          assert_nil errors, "errors should have been nil"
        end

        def test_assert_all_commands_run
          CLI::Kit::System.fake('banana', success: true)
          CLI::Kit::System.fake('kiwi', success: true)
          CLI::Kit::System.fake('apple', success: true)
          CLI::Kit::System.fake('orange', success: true)

          CLI::Kit::System.system('banana').success?
          CLI::Kit::System.capture2('kiwi').last.success?
          CLI::Kit::System.capture2e('apple').last.success?
          CLI::Kit::System.capture3('orange').last.success?

          errors = assert_all_commands_run(should_raise: false)
          assert_nil errors
        end

        def test_when_commands_run_properly
          CLI::Kit::System.fake('banana', success: true)
          assert CLI::Kit::System.system('banana').success?
        end
      end
    end
  end
end
