# typed: ignore
# frozen_string_literal: true
require "project_types/rails/test_helper"

module Rails
  class GemTest < MiniTest::Test
    include TestHelpers::FakeUI

    def setup
      super
      @home = Dir.mktmpdir
      @context.setenv("HOME", @home)
    end

    def teardown
      @context.setenv("GEM_HOME", nil)
      @context.setenv("GEM_PATH", nil)
      super
    end

    def test_install_installs_with_gem_home_unpopulated
      @context.expects(:system).with("gem", "install", "mygem")
      Gem.install(@context, "mygem")
    end

    def test_install_installs_gem_with_version
      @context.expects(:system).with("gem", "install", "mygem", "-v", "> 5.0.0")
      Gem.install(@context, "mygem", "> 5.0.0")
    end

    def test_install_installs_with_gem_home_populated
      @context.setenv("GEM_HOME", "#{@home}/.gem/ruby/#{RUBY_VERSION}")
      @context.expects(:system).with("gem", "install", "mygem")
      Gem.install(@context, "mygem")
    end

    def test_install_does_not_install_if_installed
      @context.setenv("GEM_HOME", "#{@home}/.gem/ruby/#{RUBY_VERSION}")
      @context.setenv("GEM_PATH", "")
      Dir.expects(:glob).with("#{@home}/.gem/ruby/#{RUBY_VERSION}/gems/mygem-*").returns([
        "#{@home}/.gem/ruby/#{RUBY_VERSION}/gems/mygem-1.0.0",
      ]).at_least_once
      @context.expects(:system).with("gem", "install", "mygem").never
      Gem.install(@context, "mygem")
    end

    def test_gem_home_returns_proper_path
      @context.expects(:capture2e).with("gem", "environment", "home").returns(
        ["#{@home}/.gem/ruby/#{RUBY_VERSION}\n", mock(success?: true)]
      )
      assert_equal("#{@home}/.gem/ruby/#{RUBY_VERSION}", Gem.gem_home(@context))
    end

    def test_gem_path_returns_proper_path
      tmpdir1 = Dir.mktmpdir
      tmpdir2 = Dir.mktmpdir
      @context.expects(:capture2e).with("gem", "environment", "home").returns(
        ["#{@home}/.gem/ruby/#{RUBY_VERSION}\n", mock(success?: true)]
      )
      @context.expects(:capture2e).with("gem", "environment", "path").returns(
        ["#{tmpdir1}:#{tmpdir2}\n", mock(success?: true)]
      )
      assert_equal("#{@home}/.gem/ruby/#{RUBY_VERSION}:#{tmpdir1}:#{tmpdir2}", Gem.gem_path(@context))
    end
  end
end
