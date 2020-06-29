# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  class ThemekitTest < MiniTest::Test
    def test_themekit_install
      Theme::Tasks::EnsureThemekitInstalled.expects(:call).with(@context)
      Themekit.ensure_themekit_installed(@context)
    end

    def test_create_theme_successful
      context = ShopifyCli::Context.new
      stat = mock
      context.expects(:system)
        .with(Themekit::THEMEKIT,
              'new',
              '--password=boop',
              '--store=shop.myshopify.com',
              '--name=My Theme')
        .returns(stat)
      stat.stubs(:success?).returns(true)
      assert(Themekit.create(context, password: 'boop', store: 'shop.myshopify.com', name: 'My Theme'))
    end

    def test_create_theme_unsuccessful
      context = ShopifyCli::Context.new
      stat = mock
      context.expects(:system)
        .with(Themekit::THEMEKIT,
              'new',
              '--password=boop',
              '--store=shop.com',
              '--name=My Theme')
        .returns(stat)
      stat.stubs(:success?).returns(false)
      refute(Themekit.create(context, password: 'boop', store: 'shop.com', name: 'My Theme'))
    end
  end
end
