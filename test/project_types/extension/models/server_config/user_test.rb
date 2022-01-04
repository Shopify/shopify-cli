# typed: ignore
require "test_helper"

module Extension
  module Models
    module ServerConfig
      class UserTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_extension_config_user_can_be_instantiated_with_valid_attributes
          assert_nothing_raised do
            ServerConfig::User.new
          end
        end
      end
    end
  end
end
