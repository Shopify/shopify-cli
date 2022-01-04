# typed: ignore
module TestHelpers
  module FakeUI
    class FakeSpinner
      def update_title(*); end

      def wait; end
    end

    class FakeProgress
      def tick(*); end
    end

    def setup
      super
      CLI::UI::Frame.stubs(:open).yields
      CLI::UI::SpinGroup.any_instance.stubs(:add).yields(FakeSpinner.new)
      CLI::UI::Progress.stubs(:progress).yields(FakeProgress.new)
    end
  end
end
