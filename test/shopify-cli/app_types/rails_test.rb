require 'test_helper'

module ShopifyCli
  module AppTypes
    class RailsTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
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

      def test_server_command
        @context.stubs(:project).returns(
          Project.at(File.join(FIXTURE_DIR, 'app_types/rails'))
        ).at_least_once
        cmd = ShopifyCli::Commands::Serve.new(@context)
        @context.expects(:system).with(
          "PORT=8081 bin/rails server"
        )
        cmd.call([], nil)
      end

      def test_open_command
        @context.stubs(:project).returns(
          Project.at(File.join(FIXTURE_DIR, 'app_types/rails'))
        ).at_least_once
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
