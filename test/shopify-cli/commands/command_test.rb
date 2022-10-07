require "test_helper"

module ShopifyCLI
  module Commands
    class CommandTest < MiniTest::Test
      def test_non_existant
        io = capture_io do
          assert_raises(ShopifyCLI::AbortSilent) do
            run_cmd("foobar")
          end
        end

        assert_match(/foobar.*was not found/, io.join)
      end

      def test_calls_help_with_h_flag
        io = capture_io do
          run_cmd("login -h")
        end

        assert_match(CLI::UI.fmt(Login.help), io.join)
      end

      def test_calls_help_with_subcommand_h_flag
        io = capture_io do
          run_cmd("populate customer --help")
        end

        assert_match(CLI::UI.fmt(ShopifyCLI::Commands::Populate::Customer.help), io.join)
      end

      def test_check_version_when_it_is_activated
        Environment.stubs(:test?).returns(false)
        Environment.stubs(:run_as_subprocess?).returns(false)

        context = mock
        context.expects(:warn)

        Command.check_version(
          version(1),
          range: range(2, 4),
          runtime: "Ruby",
          context: context
        )
      end

      def test_check_version_when_running_in_a_test_environment
        Environment.stubs(:test?).returns(true)
        Environment.stubs(:run_as_subprocess?).returns(false)

        context = mock
        context.expects(:warn).never

        Command.check_version(
          version(1),
          range: range(2, 4),
          runtime: "Ruby",
          context: context
        )
      end

      def test_check_version_when_running_as_subprocess
        Environment.stubs(:test?).returns(false)
        Environment.stubs(:run_as_subprocess?).returns(true)

        context = mock
        context.expects(:warn).never

        Command.check_version(
          version(1),
          range: range(2, 4),
          runtime: "Ruby",
          context: context
        )
      end

      [
        "",
        "http://",
        "https://",
        "invalidoption=",
        "invalidoption=https://",
        ["store=", false],
        ["shop=", false],
        ["s=", false, "-s="],
      ].each do |prefix, correction_expected = true, full_prefix = "--#{prefix}"|
        store_name = "mystore.myshopify.com"
        store_name_with_prefix = "#{full_prefix}#{store_name}"

        define_method("test_calls_with#{"_prefix_#{prefix}" unless prefix.empty?}_store_as_raw_param") do
          io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
            run_cmd("help login #{store_name_with_prefix}")
          end

          if correction_expected
            assert_message_output(io: io, expected_content: [
              @context.message(
                "core.errors.option_parser.invalid_option_store_equals",
                store_name_with_prefix, store_name
              ),
            ])
          else
            assert_message_output(io: io, expected_content: [
              @context.message("core.errors.option_parser.invalid_option", store_name_with_prefix),
            ])
          end
        end
      end

      private

      def version(major)
        stub(
          major: major,
          minor: 0,
          patch: 0
        )
      end

      def range(from, to)
        stub(
          from: version(from),
          to: version(to),
        )
      end
    end
  end
end
