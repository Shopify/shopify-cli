module Minitest
  module Assertions
    def assert_nothing_raised(*)
      yield
    end
  end

  class Test
    FIXTURE_DIR = File.expand_path("fixtures", File.dirname(__FILE__))
    CONFIG_FILE = CLI::Kit::Config.new(tool_name: ShopifyCLI::TOOL_NAME).file

    include TestHelpers::Project

    def setup
      @minitest_ext_setup_called = true
      if File.exist?(CONFIG_FILE)
        @config_sha_before = Digest::SHA256.hexdigest(File.read(CONFIG_FILE))
      end
      project_context("project")
      ::ShopifyCLI::Project.clear
      super
    end

    def teardown
      # Some tests stub the File class, but we need to call the real methods when checking if the config file has
      # changed.
      #
      # We could unstub them individually:
      #  File.unstub(:read)
      #  File.unstub(:exist?)
      #
      # Or we can use `mocha_teardown` which is documented as "only for use by authors of test libraries" but seems safe
      # here.

      mocha_teardown

      if File.exist?(CONFIG_FILE)
        @config_sha_after = Digest::SHA256.hexdigest(File.read(CONFIG_FILE))
      end

      raise "Local #{CONFIG_FILE} was modified by a test" unless @config_sha_before == @config_sha_after

      unless @minitest_ext_setup_called
        raise "teardown called without setup - you may have forgotten to call `super`"
      end

      @minitest_ext_setup_called = nil
      super
    end

    def run_cmd(cmd, split_cmd = true)
      stub_prompt_for_cli_updates
      stub_new_version_check

      new_cmd = split_cmd ? cmd.split : cmd
      ShopifyCLI::Core::EntryPoint.call(new_cmd, @context)
    end

    def capture_io(strip_ansi: false, &block)
      cap = CLI::UI::StdoutRouter::Capture.new(with_frame_inset: true, &block)
      @context.output_captured = true if @context
      cap.run
      @context.output_captured = false if @context
      [cap.stdout, cap.stderr].map do |s|
        strip_ansi ? CLI::UI::ANSI.strip_codes(s) : s
      end
    end

    def capture_io_and_assert_raises(exception_class)
      io = []
      io << capture_io do
        exception = assert_raises(exception_class) { yield }
        io << CLI::UI.fmt(exception.message.gsub("{{x}} ", ""))
      end
    end

    def assert_message_output(io:, expected_content:)
      all_output = io.join

      Array(expected_content).each do |expected|
        assert_includes all_output, CLI::UI.fmt(expected)
      end
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

    def stub_prompt_for_cli_updates
      ShopifyCLI::Config.stubs(:get_section).with("autoupdate").returns("enabled" => "true")
    end

    def stub_new_version_check
      stub_request(:get, ShopifyCLI::Context::GEM_LATEST_URI)
        .with(headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Host" => "rubygems.org",
          "User-Agent" => "Ruby",
        })
        .to_return(status: 200, body: "{\"version\":\"#{ShopifyCLI::VERSION}\"}", headers: {})
    end
  end
end
