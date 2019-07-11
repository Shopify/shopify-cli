require 'test_helper'
require 'semantic/semantic'

module ShopifyCli
  module AppTypes
    class RailsBuildTest < MiniTest::Test
      def setup
        root = Dir.mktmpdir
        @context = TestHelpers::FakeContext.new(root: root)
        @app = ShopifyCli::AppTypes::Rails.new(ctx: @context)
      end

      def test_build_creates_rails_app
        File.stubs(:open).with(File.join(
          @context.root,
          'config',
          'initializers',
          'user_agent.rb'
        ), 'w').returns(nil)
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'rails')
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'bundler', '~>1.0')
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'bundler', '~>2.0')
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'rails'), 'new', 'test-app'
        )
        File.expects(:open).with(File.join(@context.root, 'Gemfile'), 'a')
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'bundle'),
          'install',
          chdir: @context.root
        )
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'rails'),
          'generate',
          'shopify_app',
          chdir: @context.root
        )
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'rails'),
          'db:migrate',
          'RAILS_ENV=development',
          chdir: @context.root
        )
        @context.expects(:system).with(
          ShopifyCli::Helpers::Gem.binary_path_for(@context, 'spring'),
          'stop',
          chdir: @context.root
        )
        io = capture_io do
          @app.build('test-app')
        end
        output = io.join

        assert_match(
          CLI::UI.fmt('Run {{command:shopify serve}} to start the local development server'),
          output
        )
      end

      def test_check_dependencies_exits_if_incorrect_ruby_version
        Helpers::Ruby.expects(:version).returns(Semantic::Version.new('2.3.7'))
        assert_raises ShopifyCli::Abort do
          @app.check_dependencies
        end
      end
    end

    class RailsTest < MiniTest::Test
      include TestHelpers::Project
      include TestHelpers::FakeUI

      def setup
        super
        project_context('app_types', 'rails')
        @app = ShopifyCli::AppTypes::Rails.new(ctx: @context)
        Helpers::EnvFile.any_instance.stubs(:write)
      end

      def test_server_command
        cmd = ShopifyCli::Commands::Serve.new(@context)
        @context.expects(:system).with(
          "PORT=8081 bin/rails server"
        )
        cmd.call([], nil)
      end

      def test_open_command
        cmd = ShopifyCli::Commands::Open.new(@context)
        @context.expects(:system).with(
          'open',
          'https://example.com/login?shop=my-test-shop.myshopify.com'
        )
        cmd.call([], nil)
      end
    end
  end
end
