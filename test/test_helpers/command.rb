module TestHelpers
  module Command
    def setup
      ShopifyCLI::Command.stubs(:check_node_version)
      ShopifyCLI::Command.stubs(:check_node_version)
      super
    end
  end
end
