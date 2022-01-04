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

      ["", "http://", "https://", "invalidoption=", "invalidoption=https://"].each do |prefix|
        store_name = "mystore.myshopify.com"
        store_name_with_prefix = "--#{prefix}#{store_name}"

        define_method("test_calls_with#{"_prefix_#{prefix}" unless prefix.empty?}_store_as_raw_param") do
          io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
            run_cmd("login #{store_name_with_prefix}")
          end

          assert_message_output(io: io, expected_content: [
            @context.message("core.errors.option_parser.invalid_option_store_equals", store_name_with_prefix, store_name),
          ])
        end
      end
    end
  end
end
