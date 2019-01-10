module Minitest
  class Test
    def capture_io(&block)
      cap = CLI::UI::StdoutRouter::Capture.new(with_frame_inset: true, &block)
      cap.run
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
