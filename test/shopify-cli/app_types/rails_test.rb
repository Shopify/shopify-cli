require 'test_helper'

module ShopifyCli
  module AppTypes
    class RailsTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        super
        @app = ShopifyCli::AppTypes::Rails.new(name: 'test-app', ctx: @context)
      end

      def test_build_creates_rails_app
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'rails')
        ShopifyCli::Helpers::Gem.expects(:install).with(@context, 'bundler')
        CLI::UI.expects(:ask).twice.returns('apikey', 'apisecret')
        @context.expects(:system).with(
          "~/.gem/ruby/#{RUBY_VERSION}/bin/rails", 'new', 'test-app'
        )
        @context.expects(:system).with('echo', '"gem \'shopify_app\'"', '>>', 'Gemfile')
        @context.expects(:system).with(
          "~/.gem/ruby/#{RUBY_VERSION}/bin/bundle", 'install', chdir: @context.root
        )
        @context.expects(:system).with(
          "~/.gem/ruby/#{RUBY_VERSION}/bin/rails",
          'generate',
          'shopify_app',
          '--api_key apikey',
          '--secret apisecret',
        )
        io = capture_io do
          @app.build
        end
        output = io.join

        assert_match(
          CLI::UI.fmt('Run {{command:shopify serve}} to start the app server'),
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
