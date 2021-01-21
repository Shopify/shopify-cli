# frozen_string_literal: true

require "project_types/script/test_helper"
require "project_types/script/layers/infrastructure/fake_extension_point_repository"

describe Script::Layers::Application::SupportedLanguages do
  include TestHelpers::FakeFS

  let(:instance) { Script::Layers::Application::SupportedLanguages }

  describe '.all' do
    subject { instance.all }

    describe 'when beta feature flag is on' do
      before do
        ShopifyCli::Feature.expects(:enabled?).with(:scripts_beta_languages).returns(true)
      end

      it 'should return all languages' do
        assert_equal %w(AssemblyScript Rust), subject
      end
    end

    describe 'when beta feature flag is off' do
      before do
        ShopifyCli::Feature.expects(:enabled?).with(:scripts_beta_languages).returns(false)
      end

      it 'should return only stable languages' do
        assert_equal %w(AssemblyScript), subject
      end
    end
  end
end
