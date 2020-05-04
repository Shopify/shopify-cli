# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Layers::Application::EnableScript do
  describe '.call' do
    let(:api_key) { 'api_key' }
    let(:shop_domain) { 'shop_domain' }
    let(:configuration) { '{}' }
    let(:extension_point_type) { 'extension_point_type' }
    let(:title) { 'title' }

    subject do
      Script::Layers::Application::EnableScript.call(
        ctx: @context,
        api_key: api_key,
        shop_domain: shop_domain,
        configuration: configuration,
        extension_point_type: extension_point_type,
        title: title
      )
    end

    it 'should authenticate and make enable request' do
      Script::Layers::Infrastructure::ScriptService.any_instance.expects(:enable).with(
        api_key: api_key,
        shop_domain: shop_domain,
        configuration: configuration,
        extension_point_type: extension_point_type,
        title: title
      )
      capture_io { subject }
    end
  end
end
