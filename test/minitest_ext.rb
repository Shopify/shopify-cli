require 'digest'

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
      begin
        @old = Digest::SHA256.hexdigest(File.read(File.expand_path("~/.config/shopify/config")))
      rescue Errno::ENOENT
      end
      @minitest_ext_setup_called = true
      project_context('project')
      ::ShopifyCli::Project.clear
      super
    end

    def teardown

      unless @minitest_ext_setup_called
        raise "teardown called without setup - you may have forgotten to call `super`"
      end

      @minitest_ext_setup_called = nil
      super
      # puts
      # puts @old
      # puts @new
      # @new = Digest::SHA256.hexdigest(File.read(File.expand_path("~/.config/shopify/config")))
      # raise unless @old == @new
    end

    def run_cmd(cmd, split_cmd = true)
      stub_prompt_for_cli_updates
      stub_monorail_log_git_sha
      stub_new_version_check

      new_cmd = split_cmd ? cmd.split : cmd
      ShopifyCli::Core::EntryPoint.call(new_cmd, @context)
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

    def stub_monorail_log_git_sha
      ShopifyCli::Git.stubs(:sha).returns("bb6f42193239a248f054e5019e469bc75f3adf1b")
    end

    def stub_prompt_for_cli_updates
      ShopifyCli::Config.stubs(:get_section).with("autoupdate").returns(stub("key?" => true))
    end

    def stub_new_version_check
      stub_request(:get, ShopifyCli::Context::GEM_LATEST_URI)
        .with(headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'rubygems.org',
          'User-Agent' => 'Ruby',
        })
        .to_return(status: 200, body: "{\"version\":\"#{ShopifyCli::VERSION}\"}", headers: {})
    end
  end
end
