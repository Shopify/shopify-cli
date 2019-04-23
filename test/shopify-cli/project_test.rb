# frozen_string_literal: true
require 'test_helper'

module ShopifyCli
  class ProjectTest < MiniTest::Test
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
  end
end
