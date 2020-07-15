# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Tasks
    class EnsureThemekitInstalledTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
      end

      def test_does_nothing_if_themekit_installed
        File.expects(:exist?).with(EnsureThemekitInstalled::FILENAME).returns(true)
        assert_nothing_raised do
          EnsureThemekitInstalled.call(@context)
        end
      end

      def test_installs_and_makes_executable_if_not_installed
        File.expects(:exist?).with(EnsureThemekitInstalled::FILENAME).returns(false)
        stub_releases
        stub_themekit_file_write
        Digest::MD5.expects(:file).with(EnsureThemekitInstalled::FILENAME).returns('boop')
        FileUtils.expects(:chmod).with('+x', EnsureThemekitInstalled::FILENAME)

        EnsureThemekitInstalled.call(@context)
      end

      def test_deletes_if_bad_digest
        File.expects(:exist?).with(EnsureThemekitInstalled::FILENAME).returns(false)
        stub_releases
        stub_themekit_file_write
        Digest::MD5.expects(:file).with(EnsureThemekitInstalled::FILENAME).returns('mlem')
        FileUtils.expects(:chmod).with('+x', EnsureThemekitInstalled::FILENAME).never
        FileUtils.expects(:rm).with(EnsureThemekitInstalled::FILENAME)

        EnsureThemekitInstalled.call(@context)
      end

      def test_fails_gracefully_if_errors
        File.expects(:exist?).with(EnsureThemekitInstalled::FILENAME).returns(false)
        stub_request(:get, EnsureThemekitInstalled::URL).to_return(status: 504)
        File.expects(:write)
          .with(EnsureThemekitInstalled::FILENAME, 'this is data').never
        Digest::MD5.expects(:file).with(EnsureThemekitInstalled::FILENAME).never
        FileUtils.expects(:chmod).with('+x', EnsureThemekitInstalled::FILENAME).never
        FileUtils.expects(:rm).with(EnsureThemekitInstalled::FILENAME).never

        assert_nothing_raised do
          EnsureThemekitInstalled.call(@context)
        end
      end

      private

      def stub_releases
        stub_request(:get, EnsureThemekitInstalled::URL)
          .to_return(body: { "platforms": [
            {
              "name": 'darwin-amd64',
              "version": '123',
              "url": 'http://www.website.ca',
              "digest": 'boop',
            },
            {
              "name": 'linux-amd64',
              "version": '123',
              "url": 'http://www.website.ca',
              "digest": 'boop',
            },
            {
              "name": 'windows-amd64',
              "version": '123',
              "url": 'http://www.website.ca',
              "digest": 'boop',
            },
          ] }.to_json)
      end

      def stub_themekit_file_write
        stub_request(:get, 'http://www.website.ca')
          .to_return(body: 'this is data')

        File.expects(:write)
          .with(EnsureThemekitInstalled::FILENAME, 'this is data')
      end
    end
  end
end
