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
      assert(Themekit.create(context, password: 'boop', store: 'shop.myshopify.com', name: 'My Theme', env: nil))
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
      refute(Themekit.create(context, password: 'boop', store: 'shop.com', name: 'My Theme', env: nil))
    end

    def test_push_deploy_successful
      context = ShopifyCli::Context.new
      stat = mock

      context.expects(:system)
        .with(Themekit::THEMEKIT,
              'deploy')
        .returns(stat)
      stat.stubs(:success?).returns(true)
      assert(Themekit.push(context, files: [], flags: [], remove: nil, env: nil))
    end

    def test_push_deploy_successful_with_nil
      context = ShopifyCli::Context.new
      stat = mock

      context.expects(:system)
        .with(Themekit::THEMEKIT,
              'deploy')
        .returns(stat)
      stat.stubs(:success?).returns(true)
      assert(Themekit.push(context, files: nil, flags: nil, remove: nil, env: nil))
    end

    def test_push_remove_successful
      context = ShopifyCli::Context.new
      stat = mock

      context.expects(:system)
        .with(Themekit::THEMEKIT,
              'remove',
              'file.liquid',
              'another_file.liquid')
        .returns(stat)
      stat.stubs(:success?).returns(true)
      assert(Themekit.push(context, files: ['file.liquid', 'another_file.liquid'], flags: [], remove: true, env: nil))
    end

    def test_push_deploy_unsuccessful
      context = ShopifyCli::Context.new
      stat = mock

      context.expects(:system)
        .with(Themekit::THEMEKIT,
             'deploy')
        .returns(stat)
      stat.stubs(:success?).returns(false)
      refute(Themekit.push(context, files: [], flags: [], remove: nil, env: nil))
    end

    def test_push_remove_unsuccessful
      context = ShopifyCli::Context.new
      stat = mock

      context.expects(:system)
        .with(Themekit::THEMEKIT,
              'remove',
              'file.liquid',
              'another_file.liquid')
        .returns(stat)
      stat.stubs(:success?).returns(false)
      refute(Themekit.push(context, files: ['file.liquid', 'another_file.liquid'], flags: [], remove: true, env: nil))
    end

    def test_deploy_successful
      context = ShopifyCli::Context.new
      stat = mock

      Themekit.expects(:push).with(context, env: nil).returns(true)
      context.expects(:done).with(context.message('theme.deploy.info.pushed'))

      context.expects(:system)
        .with(Themekit::THEMEKIT,
             'publish')
        .returns(stat)
      stat.stubs(:success?).returns(true)

      assert(Themekit.deploy(context, env: nil))
    end

    def test_deploy_push_fail
      context = ShopifyCli::Context.new

      Themekit.expects(:push).with(context, env: nil).returns(false)
      context.expects(:system).with(Themekit::THEMEKIT, 'publish').never

      assert_raises CLI::Kit::Abort do
        Themekit.deploy(context, env: nil)
      end
    end

    def test_deploy_publish_fail
      context = ShopifyCli::Context.new
      stat = mock

      Themekit.expects(:push).with(context, env: nil).returns(true)
      context.expects(:done).with(context.message('theme.deploy.info.pushed'))

      context.expects(:system)
        .with(Themekit::THEMEKIT,
              'publish')
        .returns(stat)
      stat.stubs(:success?).returns(false)

      refute(Themekit.deploy(context, env: nil))
    end

    def test_connect_successful
      context = ShopifyCli::Context.new
      stat = mock
      context.expects(:system)
        .with(Themekit::THEMEKIT,
              'get',
              '--password=boop',
              '--store=shop.com',
              '--themeid=2468')
        .returns(stat)
      stat.stubs(:success?).returns(true)
      assert(Themekit.connect(context, store: 'shop.com', password: 'boop', themeid: '2468', env: nil))
    end

    def test_connect_unsuccessful
      context = ShopifyCli::Context.new
      stat = mock
      context.expects(:system)
        .with(Themekit::THEMEKIT,
              'get',
              '--password=boop',
              '--store=shop.com',
              '--themeid=2468')
        .returns(stat)
      stat.stubs(:success?).returns(false)
      refute(Themekit.connect(context, store: 'shop.com', password: 'boop', themeid: '2468', env: nil))
    end

    def test_serve_successful
      context = ShopifyCli::Context.new
      stat = mock

      context.expects(:capture2e)
        .with(Themekit::THEMEKIT, 'open')
        .returns(['out', stat])
      stat.stubs(:success?).returns(true)
      context.expects(:puts).with('out')

      context.expects(:system)
        .with(Themekit::THEMEKIT, 'watch')

      Themekit.serve(context, env: nil)
    end

    def test_aborts_serve_if_open_fails
      context = ShopifyCli::Context.new
      stat = mock

      context.expects(:capture2e)
        .with(Themekit::THEMEKIT, 'open')
        .returns(['out', stat])
      stat.stubs(:success?).returns(false)
      context.expects(:puts).with('out')

      context.expects(:system)
        .with(Themekit::THEMEKIT, 'watch')
        .never

      assert_raises(ShopifyCli::Abort) do
        Themekit.serve(context, env: nil)
      end
    end
  end
end
