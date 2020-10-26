# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  class ContextTest < MiniTest::Test
    include TestHelpers::FakeFS

    def setup
      super
      @ctx = Context.new
    end

    def test_write_writes_to_file_in_project
      @ctx.root = Dir.mktmpdir
      @ctx.write('.env', 'foobar')
      assert File.exist?(File.join(@ctx.root, '.env'))
    end

    def test_mac_matches
      @ctx.expects(:uname).returns('x86_64-apple-darwin19.3.0').times(3)
      assert(@ctx.mac?)
      assert_equal(:mac, @ctx.os)
      refute(@ctx.linux?)
    end

    def test_linux_matches
      @ctx.expects(:uname).returns('x86_64-pc-linux-gnu').times(3)
      assert(@ctx.linux?)
      assert_equal(:linux, @ctx.os)
      refute(@ctx.mac?)
    end

    def test_open_url_outputs_url_to_open
      url = 'http://cutekitties.com'
      @ctx.stubs(:mac?).returns(true)
      @ctx.expects(:puts).with(@context.message('core.context.open_url', url))
      @ctx.open_url!(url)
    end

    def test_check_for_new_version_if_no_config_section
      ShopifyCli::Config
        .expects(:get)
        .returns(false)
      ShopifyCli::Config
        .expects(:set)
        .once
      mock_rubygems_https_call(response_body: "{\"version\":\"99.99.99\"}")

      assert_equal("99.99.99", @ctx.new_version)
    end

    def test_no_check_for_new_version_if_config_section_and_interval_not_passed
      ShopifyCli::Config
        .expects(:get)
        .returns(Time.now.to_i - 3600)
      Net::HTTP
        .expects(:get_response)
        .with(ShopifyCli::Context::GEM_LATEST_URI)
        .never

      refute(@ctx.new_version)
    end

    def test_check_for_new_version_if_config_section_and_interval_passed
      ShopifyCli::Config
        .expects(:get)
        .returns(Time.now.to_i - 86500)
      ShopifyCli::Config
        .expects(:set)
        .once
      mock_rubygems_https_call(response_body: "{\"version\":\"99.99.99\"}")

      assert_equal("99.99.99", @ctx.new_version)
    end

    def test_check_for_new_version_returns_nil_if_https_call_returns_garbage
      ShopifyCli::Config
        .expects(:get)
        .returns(Time.now.to_i - 86500)
      ShopifyCli::Config
        .expects(:set)
        .once
      mock_rubygems_https_call(response_body: "ad098q907b\n90979a*(&*^*%klhfadkh}")

      refute(@ctx.new_version)
    end

    def test_check_for_new_version_returns_nil_if_https_call_times_out
      ShopifyCli::Config
        .expects(:get)
        .returns(Time.now.to_i - 86500)
      ShopifyCli::Config
        .expects(:set)
        .once
      Net::HTTP
        .expects(:get_response)
        .with(ShopifyCli::Context::GEM_LATEST_URI)
        .raises(Net::ReadTimeout)

      refute(@ctx.new_version)
    end

    private

    def mock_rubygems_https_call(response_body:)
      stub_request(:get, ShopifyCli::Context::GEM_LATEST_URI)
        .with(headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'rubygems.org',
          'User-Agent' => 'Ruby',
        })
        .to_return(status: 200, body: response_body, headers: {})
    end
  end
end
