# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  module Helpers
    class GemTest < MiniTest::Test
      include TestHelpers::Context

      def test_install_installs_with_gem_home_unpopulated
        @context.expects(:mkdir_p).with(
          "#{@context.getenv('HOME')}/.gem/ruby/#{RUBY_VERSION}"
        ).at_least_once
        @context.expects(:setenv).with(
          'GEM_HOME',
          "#{@context.getenv('HOME')}/.gem/ruby/#{RUBY_VERSION}"
        ).at_least_once
        @context.expects(:system).with('gem install mygem')
        Gem.install(@context, 'mygem')
      end

      def test_install_installs_with_gem_home_populated
        @context.setenv('GEM_HOME', '~/.gem/ruby/2.5.5')
        @context.expects(:system).with('gem install mygem')
        Gem.install(@context, 'mygem')
      end

      def test_install_does_not_install_if_installed
        @context.setenv('GEM_HOME', "~/.gem/ruby/#{RUBY_VERSION}")
        Dir.expects(:glob).with("~/.gem/ruby/#{RUBY_VERSION}/gems/mygem-*").returns([
          "~/.gem/ruby/#{RUBY_VERSION}/gems/mygem-1.0.0",
        ]).at_least_once
        @context.expects(:system).with('gem install mygem').never
        Gem.install(@context, 'mygem')
      end
    end
  end
end
