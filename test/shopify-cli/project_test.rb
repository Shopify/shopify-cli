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
        FileUtils.mkdir_p("#{dir}/a/b/c/d")
        FileUtils.touch("#{dir}/.shopify-cli.yml")
        assert_equal(dir, Project.at("#{dir}/a/b/c/d").directory)
      end
    end

    def test_current_fails_if_no_config
      Dir.mktmpdir do |dir|
        assert_raises ShopifyCli::Abort do
          FileUtils.mkdir_p("#{dir}/a/b/c/d")
          Project.at("#{dir}/a/b/c/d")
        end
      end
    end

    def test_write_writes_yaml
      FileUtils.touch(".shopify-cli.yml")
      ShopifyCli::Project.write(@context, :app, :node)
      assert_equal :node, ShopifyCli::Project.at(@context.root).config['app_type']
    end
  end
end
