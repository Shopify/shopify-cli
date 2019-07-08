module Minitest
  module Assertions
    def assert_nothing_raised(*)
      yield
    end
  end

  class Test
    FIXTURE_DIR = File.expand_path('fixtures', File.dirname(__FILE__))

    class FakeSpinner
      def update_title(*); end

      def wait; end
    end

    def setup
      super
      CLI::UI::Frame.stubs(:open).yields
      CLI::UI::SpinGroup.any_instance.stubs(:add).yields(FakeSpinner.new)
    end

    def capture_io(&block)
      cap = CLI::UI::StdoutRouter::Capture.new(with_frame_inset: true, &block)
      @context.output_captured = true if @context
      cap.run
      @context.output_captured = false if @context
      [cap.stdout, cap.stderr]
    end

    def to_s # :nodoc:
      if passed? && !skipped?
        return location
      end
      failures.flat_map do |failure|
        [
          "#{failure.result_label}:",
          "#{location}:",
          failure.message.force_encoding(Encoding::UTF_8),
        ]
      end.join("\n")
    end
  end
end
