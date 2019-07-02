require 'test_helper'

module ShopifyCli
  module AppTypes
    class RailsBuildTest < MiniTest::Test
      def setup
        root = Dir.mktmpdir
        @context = TestHelpers::FakeContext.new(
          root: root,
          env: {
            'HOME' => '~',
            'XDG_CONFIG_HOME' => root,
          }
        )
        @app = ShopifyCli::AppTypes::Rails.new(ctx: @context)
        @context.app_metadata = {
          api_key: 'api_key',
          secret: 'secret',
        }
      end

      def test_build_creates_rails_app
        File.stubs(:open).with(File.join(
          @context.root,
          'config',
          'initializers',
          'user_agent.rb'
        ), 'w').returns(nil)
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'rails')
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'bundler')
        @context.expects(:system).with(
          "~/.gem/ruby/#{RUBY_VERSION}/bin/rails", 'new', 'test-app'
        )
        File.expects(:open).with(File.join(@context.root, 'Gemfile'), 'a')
        @context.expects(:system).with(
          "~/.gem/ruby/#{RUBY_VERSION}/bin/bundle", 'install', chdir: @context.root
        )
        @context.expects(:system).with(
          "~/.gem/ruby/#{RUBY_VERSION}/bin/rails",
          'generate',
          'shopify_app',
          '--api_key api_key',
          '--secret secret',
          chdir: @context.root
        )
        @context.expects(:system).with(
          "~/.gem/ruby/#{RUBY_VERSION}/bin/rails",
          'db:migrate',
          'RAILS_ENV=development',
          chdir: @context.root
        )
        @context.expects(:system).with(
          'gem',
          'install',
          'bundler',
          '-v',
          '~>1.0',
          chdir: @context.root
        )
        @context.expects(:system).with(
          'gem',
          'install',
          'bundler',
          '-v',
          '~>2.0',
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
    end

    class RailsTest < MiniTest::Test
      include TestHelpers::Project

      def setup
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
