# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  class ProjectTest < MiniTest::Test
    def setup
      @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
      FileUtils.cd(@context.root)
    end

    def test_directory_recurses
      Dir.mktmpdir do |dir|
        Dir.stubs(:pwd).returns("#{dir}/a/b/c/d")
        FileUtils.mkdir_p("#{dir}/a/b/c/d")
        FileUtils.touch("#{dir}/.shopify-cli.yml")
        assert_equal(dir, Project.current.directory)
      end
    end

    def test_current_fails_if_no_config
      Dir.mktmpdir do |dir|
        Dir.stubs(:pwd).returns("#{dir}/a/b/c/d")
        assert_raises ShopifyCli::Abort do
          FileUtils.mkdir_p("#{dir}/a/b/c/d")
          Project.current
        end
      end
    end

    def test_write_writes_yaml
      Dir.stubs(:pwd).returns(@context.root)
      FileUtils.touch(".shopify-cli.yml")
      ShopifyCli::Project.write(@context, :node)
      assert_equal :node, Project.current.config['app_type']
    end
  end
end
