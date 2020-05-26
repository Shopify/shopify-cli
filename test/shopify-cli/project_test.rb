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
      ShopifyCli::Project.write(@context, project_type: :node, organization_id: 42)
      assert_equal :node, Project.current.config['project_type']
      assert_equal 42, Project.current.config['organization_id']
    end

    def test_write_includes_identifiers
      Dir.stubs(:pwd).returns(@context.root)
      FileUtils.touch(".shopify-cli.yml")
      ShopifyCli::Project.write(
        @context,
        project_type: :node,
        organization_id: 42,
        other_option: true,
      )
      assert Project.current.config['other_option']
    end

    def test_project_name_returns_name
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p("#{dir}/myapp")
        FileUtils.touch("#{dir}/myapp/.shopify-cli.yml")
        FileUtils.cd("#{dir}/myapp")
        project_name = Project.project_name
        assert_equal "myapp", project_name
      end
    end

    def test_project_name_returns_name_even_if_called_from_subdirectory
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p("#{dir}/myapp/lib")
        FileUtils.touch("#{dir}/myapp/.shopify-cli.yml")
        FileUtils.cd("#{dir}/myapp/lib")
        project_name = Project.project_name
        assert_equal "myapp", project_name
      end
    end
  end
end
