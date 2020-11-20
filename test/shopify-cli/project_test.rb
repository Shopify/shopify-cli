# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  class ProjectTest < MiniTest::Test
    def setup
      super
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
      Shopifolk.stubs(:acting_as_shopify_organization?).returns(false)
      Dir.stubs(:pwd).returns(@context.root)
      FileUtils.touch(".shopify-cli.yml")
      ShopifyCli::Project.write(@context, project_type: :node, organization_id: 42)
      assert_equal :node, Project.current.config['project_type']
      assert_equal 42, Project.current.config['organization_id']
      refute Project.current.config['shopify_organization']
    end

    def test_write_writes_yaml_with_shopify_organization_field
      create_empty_config
      Shopifolk.stubs(:acting_as_shopify_organization?).returns(true)
      ShopifyCli::Project.write(@context, project_type: :node, organization_id: 42)
      assert Project.current.config['shopify_organization']
    end

    def test_write_writes_yaml_without_shopify_organization_field
      create_empty_config
      Shopifolk.stubs(:acting_as_shopify_organization?).returns(false)
      ShopifyCli::Project.write(@context, project_type: :node, organization_id: 42)
      refute Project.current.config['shopify_organization']
    end

    def test_write_includes_identifiers
      create_empty_config
      File.write(".shopify-cli.yml", YAML.dump({}))
      ShopifyCli::Project.write(
        @context,
        project_type: :node,
        organization_id: 42,
        other_option: true,
      )
      Project.clear
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

    def test_project_env_returns_nil_if_doesnt_exist
      Dir.mktmpdir do |dir|
        Dir.stubs(:pwd).returns(dir)
        FileUtils.touch("#{dir}/.shopify-cli.yml")
        assert_nil(Project.current.env)
      end
    end

    def test_project_env_returns_env_file_if_it_exists
      Dir.mktmpdir do |dir|
        Dir.stubs(:pwd).returns(dir)
        FileUtils.touch("#{dir}/.shopify-cli.yml")
        content = <<~CONTENT
          SHOPIFY_API_KEY=foo
          SHOPIFY_API_SECRET=bar
          HOST=baz
          AWSKEY=awskey
        CONTENT
        File.write(File.join(dir, '.env'), content)
        refute_nil(Project.current.env)
      end
    end

    private

    def create_empty_config
      Dir.stubs(:pwd).returns(@context.root)
      FileUtils.touch(".shopify-cli.yml")
    end
  end
end
