require 'test_helper'
require 'tmpdir'
require 'fileutils'

module CLI
  module Kit
    class ConfigTest < MiniTest::Test
      def setup
        super

        @tmpdir = Dir.mktmpdir
        @prev_xdg = ENV['XDG_CONFIG_HOME']
        ENV['XDG_CONFIG_HOME'] = @tmpdir
        @file = File.join(@tmpdir, 'tool', 'config')
        @config = Config.new(tool_name: 'tool')
      end

      def teardown
        FileUtils.rm_rf(@tmpdir)
        ENV['XDG_CONFIG_HOME'] = @prev_xdg
        super
      end

      def test_config_get_returns_false_for_not_existant_key
        refute @config.get('section', 'invalid-key-no-existing')
      end

      def test_config_get_bool_non_existant
        refute @config.get('section', 'invalid-key-no-existing') # doesn't exist yet
        refute @config.get_bool('section', 'invalid-key-no-existing') # defaults to false
      end

      def test_config_get_bool_on_string
        @config.set('section', 'foo-key', 'true')
        assert_equal('true', @config.get('section', 'foo-key')) # doesn't parse by default
        assert_equal(true, @config.get_bool('section', 'foo-key'))

        @config.set('section', 'foo-key', 'false')
        assert_equal('false', @config.get('section', 'foo-key')) # doesn't parse by default
        assert_equal(false, @config.get_bool('section', 'foo-key'))
      end

      def test_config_get_bool_on_bool
        @config.set('section', 'foo-key', true)
        assert_equal('true', @config.get('section', 'foo-key'))
        assert_equal(true, @config.get_bool('section', 'foo-key'))

        @config.set('section', 'foo-key', false)
        assert_equal('false', @config.get('section', 'foo-key'))
        assert_equal(false, @config.get_bool('section', 'foo-key'))
      end

      def test_config_get_bool_on_invalid
        @config.set('section', 'foo-key', "yes")
        assert_equal("yes", @config.get('section', 'foo-key'))

        e = assert_raises CLI::Kit::Abort do
          @config.get_bool('section', 'foo-key')
        end
        assert_equal "Invalid config: section.foo-key is expected to be true or false", e.message
      end

      def test_config_key_never_padded_with_whitespace
        # There was a bug that occured when a key was reset
        # We split on `=` and 'key ' became the new key (with a space)
        # This is a regression test to make sure that doesnt happen
        @config.set('section', 'key', 'value')
        assert_equal({ "[section]" => { "key" => "value" } }, @config.send(:all_configs))
        3.times { @config.set('section', 'key', 'value') }
        assert_equal({ "[section]" => { "key" => "value" } }, @config.send(:all_configs))
      end

      def test_config_set
        @config.set('section', 'some-key', '~/.test')
        assert_equal("[section]\nsome-key = ~/.test", File.read(@file))

        @config.set('section', 'some-key', nil)
        assert_equal '', File.read(@file)

        @config.set('section', 'some-key', '~/.test')
        @config.set('section', 'some-other-key', '~/.test')
        assert_equal("[section]\nsome-key = ~/.test\nsome-other-key = ~/.test", File.read(@file))

        assert_equal('~/.test', @config.get('section', 'some-key'))
        assert_equal("#{ENV['HOME']}/.test", @config.get_path('section', 'some-key'))
      end

      def test_config_unset
        @config.set('section', 'some-key', '~/.test')
        assert_equal("[section]\nsome-key = ~/.test", File.read(@file))
        @config.unset('section', 'some-key')
        assert_equal("", File.read(@file))
      end

      def test_config_mutli_argument_get
        @config.set('some-parent', 'some-key', 'some-value')
        assert_equal 'some-value', @config.get('some-parent', 'some-key')
      end

      def test_get_section
        @config.set('section', 'some-key', 'should not show')
        @config.set('srcpath', 'other', 'test')
        @config.set('srcpath', 'default', 'Shopify')
        assert_equal({ 'other' => 'test', 'default' => 'Shopify' }, @config.get_section('srcpath'))
      end
    end
  end
end
