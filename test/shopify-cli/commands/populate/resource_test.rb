require 'test_helper'

module ShopifyCli
  module Commands
    class Populate
      class ResourceTest < MiniTest::Test
        include TestHelpers::Context
        include TestHelpers::Schema

        def setup
          super
          Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
          @context.stubs(:project).returns(
            Project.at(File.join(FIXTURE_DIR, 'app_types/node'))
          )
        end

        def test_with_schema_args_overrides_input
          puts @context.project.directory
          resource = Product.new(ctx: @context, args: [
            '-c 1', '--title="bad jeggings"', '--variants=[{price: "4.99"}]'
          ])
          assert_equal('"bad jeggings"', resource.input.title)
          assert_equal('[{price: "4.99"}]', resource.input.variants)
        end
      end
    end
  end
end
