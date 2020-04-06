module Minitest
  module Assertions
    def assert_nothing_raised(*)
      yield
    end
  end

  class Test
    FIXTURE_DIR = File.expand_path('fixtures', File.dirname(__FILE__))

    include TestHelpers::Project

    def setup
      project_context('project')
      super
    end

    def run_cmd(cmd)
      stub_monorail_log_invocation
      ShopifyCli::Core::EntryPoint.call(cmd.split(' '), @context)
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

    private

    def stub_monorail_log_invocation
      ShopifyCli::Git.stubs(:sha).returns("bb6f42193239a248f054e5019e469bc75f3adf1b")
    end
  end
end
