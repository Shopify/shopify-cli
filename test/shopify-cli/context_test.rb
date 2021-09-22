# frozen_string_literal: true
require "test_helper"

module ShopifyCLI
  class ContextTest < MiniTest::Test
    include TestHelpers::FakeFS

    def setup
      super
      @ctx = Context.new
    end

    def test_write_writes_to_file_in_project
      @ctx.root = Dir.mktmpdir
      @ctx.write(".env", "foobar")
      assert File.exist?(File.join(@ctx.root, ".env"))
    end

    def test_binwrite_writes_to_file_in_project
      @ctx.root = Dir.mktmpdir
      filename = "bin.out"
      binary = "\x0a"
      filepath = File.join(@ctx.root, filename)
      @ctx.binwrite(filename, binary)
      assert File.exist?(filepath)
      assert_equal binary, File.binread(filepath)
    end

    def test_binread_writes_to_file_in_project
      @ctx.root = Dir.mktmpdir
      filename = "bin.out"
      binary = "\x0a"
      File.write(File.join(@ctx.root, filename), binary)
      assert_equal binary, @ctx.binread(filename)
    end

    [
      { host: "universal-arm64e-darwin20", mac: true, windows: false, linux: false },
      { host: "x86_64-apple-darwin19.3.0", mac: true, windows: false, linux: false },
      { host: "i386-apple-darwin19.3.0", mac: true, windows: false, linux: false },
      { host: "x86_64-pc-linux-gnu", mac: false, windows: false, linux: true },
      { host: "x86_64-linux-gnu", mac: false, windows: false, linux: true },
      { host: "x86-64-kfreebsd-gnu", mac: false, windows: false, linux: true },
      { host: "aarch64-linux-gnu", mac: false, windows: false, linux: true },
      { host: "arm-linux-gnueabihf", mac: false, windows: false, linux: true },
      { host: "x86_64-w64-mingw32", mac: false, windows: true, linux: false },
      { host: "CYGWIN_NT-5.1", mac: false, windows: true, linux: false },
    ].each do |test|
      define_method("test_os_matches_#{test[:host]}") do
        @ctx.stubs(:uname).returns(test[:host])

        assert(@ctx.mac?) if test[:mac]
        assert(@ctx.windows?) if test[:windows]
        assert(@ctx.linux?) if test[:linux]
        assert(@ctx.unknown_os?) if test[:unknown]

        assert_equal(:mac, @ctx.os) if test[:mac]
        assert_equal(:windows, @ctx.os) if test[:windows]
        assert_equal(:linux, @ctx.os) if test[:linux]
        assert_equal(:unknown, @ctx.os) if test[:unknown]

        refute(@ctx.mac?) unless test[:mac]
        refute(@ctx.windows?) unless test[:windows]
        refute(@ctx.linux?) unless test[:linux]
        refute(@ctx.unknown_os?) unless test[:unknown]
      end
    end

    def test_open_url_outputs_url_to_open
      url = "http://cutekitties.com"
      @ctx.stubs(:tty?).returns(false)
      @ctx.stubs(:mac?).returns(true)
      @ctx.expects(:puts).with(@context.message("core.context.open_url", url))
      @ctx.open_url!(url)
    end

    [
      { tty: true, mac: true, windows: false, linux: false, expect_output: false, expect_system: "open" },
      { tty: true, mac: false, windows: true, linux: false, expect_output: false, expect_system: "start" },
      { tty: true, mac: false, windows: false, linux: true, expect_output: false, expect_system: "xdg-open" },
      { tty: true, mac: false, windows: false, linux: true, expect_output: true, expect_system: nil },
      { tty: true, mac: false, windows: false, linux: false, expect_output: true },
      { tty: false, mac: true, windows: false, linux: false, expect_output: true },
    ].each do |test|
      define_method("test_open_browser_url_with_" +
        (test[:tty] ? "_tty" : "_no_tty") +
        (test[:mac] ? "_mac" : "") +
        (test[:windows] ? "_windows" : "") +
        (test[:linux] ? "_linux" : "") +
        (test[:expect_output] ? "_to_stdout" : "") +
        (test[:expect_system] ? "_call_system_" + test[:expect_system] : "")) do
        url = "http://shoesbycolin.com"
        @ctx.stubs(:tty?).returns(test[:tty])
        @ctx.stubs(:mac?).returns(test[:mac])
        @ctx.stubs(:windows?).returns(test[:windows])
        @ctx.stubs(:linux?).returns(test[:linux])
        @ctx.stubs(:which).returns(test[:expect_system]) if test[:linux]
        if test[:expect_output]
          @ctx.expects(:open_url!)
        else
          args = if test[:windows]
            ["#{test[:expect_system]} \"\" \"#{url}\""]
          else
            [test[:expect_system], url]
          end
          @ctx.expects(:system).with(*args)
        end
        @ctx.open_browser_url!(url)
      end
    end

    def test_check_for_new_version_if_no_config_section
      ShopifyCLI::Config
        .expects(:get)
        .returns(false)
      ShopifyCLI::Config
        .expects(:set)
        .once
      mock_rubygems_https_call(response_body: "{\"version\":\"99.99.99\"}")

      assert_equal("99.99.99", @ctx.new_version)
    end

    def test_no_check_for_new_version_if_config_section_and_interval_not_passed
      ShopifyCLI::Config
        .expects(:get)
        .returns(Time.now.to_i - 3600)
      Net::HTTP
        .expects(:get_response)
        .with(ShopifyCLI::Context::GEM_LATEST_URI)
        .never

      refute(@ctx.new_version)
    end

    def test_check_for_new_version_if_config_section_and_interval_passed
      ShopifyCLI::Config
        .expects(:get)
        .returns(Time.now.to_i - 86500)
      ShopifyCLI::Config
        .expects(:set)
        .once
      mock_rubygems_https_call(response_body: "{\"version\":\"99.99.99\"}")

      assert_equal("99.99.99", @ctx.new_version)
    end

    def test_check_for_new_version_returns_nil_if_https_call_returns_garbage
      ShopifyCLI::Config
        .expects(:get)
        .returns(Time.now.to_i - 86500)
      ShopifyCLI::Config
        .expects(:set)
        .once
      mock_rubygems_https_call(response_body: "ad098q907b\n90979a*(&*^*%klhfadkh}")

      refute(@ctx.new_version)
    end

    def test_check_for_new_version_returns_nil_if_https_call_times_out
      ShopifyCLI::Config
        .expects(:get)
        .returns(Time.now.to_i - 86500)
      ShopifyCLI::Config
        .expects(:set)
        .once
      Net::HTTP
        .expects(:get_response)
        .with(ShopifyCLI::Context::GEM_LATEST_URI)
        .raises(Net::ReadTimeout)

      refute(@ctx.new_version)
    end

    private

    def mock_rubygems_https_call(response_body:)
      stub_request(:get, ShopifyCLI::Context::GEM_LATEST_URI)
        .with(headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Host" => "rubygems.org",
          "User-Agent" => "Ruby",
        })
        .to_return(status: 200, body: response_body, headers: {})
    end
  end
end
