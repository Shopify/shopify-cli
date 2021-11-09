require "test_helper"

module ShopifyCLI
  module Services
    module App
      class ConnectServiceTest < MiniTest::Test
        include TestHelpers::Partners
        include TestHelpers::FakeUI

        def test_can_connect
          # Given
          context = ShopifyCLI::Context.new
          ShopifyCLI::Connect.any_instance.expects(:default_connect)
            .with("rails")
            .returns("rails-app")
          context.expects(:done)
            .with(context.message("core.app.connect.connected", "rails-app"))

          # When/Then
          Services::App::ConnectService.call(
            project: nil,
            app_type: :rails,
            context: context
          )
        end

        def test_warns_if_in_production
          # Given
          context = ShopifyCLI::Context.new
          project = mock("project", env: {})
          context.expects(:puts)
            .with(context.message("core.app.connect.production_warning"))
          ShopifyCLI::Connect.any_instance.expects(:default_connect)
            .with("rails")
            .returns("rails-app")
          context.expects(:done)
            .with(context.message("core.app.connect.connected", "rails-app"))

          # When/Then
          Services::App::ConnectService.call(
            project: project,
            app_type: :rails,
            context: context
          )
        end
      end
    end
  end
end
