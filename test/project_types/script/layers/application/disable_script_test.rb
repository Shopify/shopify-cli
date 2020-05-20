# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::DisableScript do
  describe '.call' do
    let(:api_key) { 'api_key' }
    let(:shop_domain) { 'shop_domain' }
    let(:extension_point_type) { 'extension_point_type' }

    subject do
      Script::Layers::Application::DisableScript
        .call(ctx: @context, api_key: api_key, shop_domain: shop_domain, extension_point_type: extension_point_type)
    end

    it 'should authenticate and make disable request' do
      Script::Layers::Infrastructure::ScriptService
        .any_instance
        .expects(:disable)
        .with(api_key: api_key, shop_domain: shop_domain, extension_point_type: extension_point_type)
      capture_io { subject }
    end
  end
end
