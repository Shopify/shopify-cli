# typed: ignore
# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::UI::PrintingSpinner do
  describe ".spin" do
    let(:ctx_root) { "/some/dir/here" }
    let(:ctx) { TestHelpers::FakeContext.new(root: ctx_root) }
    let(:title) { "title" }

    it "yields a block with a ctx parameter" do
      capture_io do
        Script::UI::PrintingSpinner.spin(ctx, title) do |ctx, *_args|
          assert_equal Script::UI::PrintingSpinner.const_get(:PrintingSpinnerContext), ctx.class
          assert_equal ctx_root, ctx.root
        end
      end
    end

    it "puts ANSI escape sequence for strings" do
      ctx_expects_puts_with_encoding("first line", "second one")
      ctx_expects_puts_with_encoding("multiple calls")
      ctx_expects_puts_with_encoding("with", "newline")

      capture_io do
        Script::UI::PrintingSpinner.spin(ctx, title) do |ctx, *_args|
          ctx.puts("first line", "second one")
          ctx.puts("multiple calls")
          ctx.puts("with\nnewline")
        end
      end
    end

    it "prints the strings" do
      out, _ = capture_subprocess_io do
        Script::UI::PrintingSpinner.spin(ctx, title) do |ctx, *_args|
          ctx.puts("lineA")
          ctx.puts("lineB")
          ctx.puts("lineC")
          ctx.puts("lineD")
        end
      end

      out = CLI::UI::ANSI.strip_codes(out)
      assert_match(/lineA\e\[K/, out)
      assert_match(/lineB\e\[K/, out)
      assert_match(/lineC\e\[K/, out)
      assert_match(/lineD\e\[K/, out)
      assert_match(/✓/, out)
    end

    it "is compatible with the spinners printing" do
      out, _ = capture_subprocess_io do
        Script::UI::PrintingSpinner.spin(ctx, title) do |ctx, spinner|
          ctx.puts("lineA")
          spinner.update_title("secondTitle")
          ctx.puts("lineB")
        end
      end

      out = CLI::UI::ANSI.strip_codes(out)
      assert_match(/lineA\e\[K/, out)
      assert_match(/secondTitle\e\[K/, out)
      assert_match(/lineB\e\[K/, out)
      assert_match(/✓/, out)
    end
  end

  private

  def ctx_expects_puts_with_encoding(*lines)
    spinner_text = "spinning.."
    encoded_input = lines.map { |line| "\e[1A\e[1G" + line + "\e[K" }.join("\e[1B\e[1G\n")
    ShopifyCLI::Context.any_instance.expects(:puts).with("#{encoded_input}\n#{spinner_text}")
    Script::UI::PrintingSpinner
      .const_get(:PrintingSpinnerContext)
      .any_instance
      .stubs(:spinner_text)
      .returns(spinner_text)
  end

  def capture_subprocess_io
    super do
      # The parent method alters stdout and stderr, which deactivates the router.
      CLI::UI::StdoutRouter.enable
      yield
    end
  ensure
    CLI::UI::StdoutRouter.ensure_activated
  end
end
