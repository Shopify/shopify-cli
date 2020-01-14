require 'test_helper'

module ShopifyCli
  module Commands
    class Serve
      class RailsServeTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          project_context('app_types', 'rails')
          Helpers::EnvFile.any_instance.stubs(:write)
          Helpers::EnvFile.any_instance.stubs(:update)
        end

        def test_server_command
          ShopifyCli::Tasks::Tunnel.stubs(:call)
          ShopifyCli::Tasks::UpdateDashboardURLS.expects(:call)
          @context.expects(:system).with(
            'bin/rails server',
            env: {
              'PORT' => '8081',
            }
          )
          run_cmd('serve')
        end
      end
    end
  end
end
