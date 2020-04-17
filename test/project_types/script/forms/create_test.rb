# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners

      def setup
        super
        ShopifyCli::ProjectType.load_type(:script)
      end

      def test_returns_all_defined_attributes_if_valid
        name = 'name'
        extension_point = 'discount'
        form = ask(name: name, extension_point: extension_point)
        assert_equal(form.name, name)
        assert_equal(form.extension_point, extension_point)
      end

      def test_returns_nil_if_no_name
        form = ask(extension_point: 'discount')
        assert_nil(form)
      end

      def test_asks_extension_point_if_no_flag
        eps = ['discount', 'another']
        Layers::Application::ExtensionPoints.stubs(:types).returns(eps)
        CLI::UI::Prompt.expects(:ask).with('Which extension point do you want to use?', options: eps)
        ask(name: 'name')
      end

      private

      def ask(name: nil, extension_point: nil)
        Create.ask(@context, [name].compact, extension_point: extension_point)
      end
    end
  end
end
