# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Forms::RunAgainstShopifyOrg do
  include TestHelpers::FakeFS

  describe ".ask" do
    let(:context) { TestHelpers::FakeContext.new(root: Dir.mktmpdir) }

    subject do
      result = nil
      capture_io { result = Script::Forms::RunAgainstShopifyOrg.ask(context, nil, {}) }
      result
    end

    describe "wants to run against shopify" do
      it "response is true" do
        CLI::UI::Prompt
          .expects(:confirm)
          .with(context.message("core.tasks.select_org_and_shop.first_party"), default: false)
          .returns(true)
        assert subject.response
      end
    end

    describe "does not want to run against shopify" do
      it "respone is false" do
        CLI::UI::Prompt
          .expects(:confirm)
          .with(context.message("core.tasks.select_org_and_shop.first_party"), default: false)
          .returns(false)
        refute subject.response
      end
    end
  end
end
