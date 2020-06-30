# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"

describe Script::Layers::Application::ExtensionPoints do
  include TestHelpers::FakeFS

  let(:language) { 'ts' }
  let(:script_name) { 'name' }
  let(:extension_point_type) { 'discount' }
  let(:extension_point_repository) { Script::Layers::Infrastructure::FakeExtensionPointRepository.new }
  let(:extension_point) { extension_point_repository.get_extension_point(extension_point_type) }

  before do
    extension_point_repository.create_extension_point(extension_point_type)
    Script::Layers::Infrastructure::ExtensionPointRepository.stubs(:new).returns(extension_point_repository)
  end

  describe '.get' do
    describe 'when extension point exists' do
      it 'should return a valid extension point' do
        ep = Script::Layers::Application::ExtensionPoints.get(type: extension_point_type)
        assert_equal extension_point, ep
      end
    end

    describe 'when extension point exists' do
      it 'should return a valid extension point' do
        assert_raises(Script::Layers::Domain::Errors::InvalidExtensionPointError) do
          Script::Layers::Application::ExtensionPoints.get(type: 'invalid')
        end
      end
    end
  end

  describe '.types' do
    it 'should return an array of all types' do
      assert_equal %w(discount unit_limit_per_order), Script::Layers::Application::ExtensionPoints.types
    end
  end
end
