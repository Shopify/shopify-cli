# typed: ignore
# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Forms::AskOrg do
  describe ".ask" do
    let(:context) { TestHelpers::FakeContext.new }

    subject do
      result = nil
      capture_io { result = Script::Forms::AskOrg.ask(context, orgs, {}) }
      result
    end

    def new_org(id, name)
      {
        "id" => id,
        "businessName" => name,
      }
    end

    describe("when asking org") do
      describe("when number of orgs == 0") do
        let(:orgs) { [] }

        it("raises NoExistingOrganizationsError") do
          assert_raises(Script::Errors::NoExistingOrganizationsError) { subject }
        end
      end

      describe("when number of orgs == 1") do
        let(:org_id) { 1 }
        let(:org_name) { "business1" }
        let(:orgs) { [new_org(org_id, org_name)] }

        it("selects the org by default") do
          selected_org_msg = context.message("script.application.ensure_env.organization", org_name, org_id)
          context.expects(:puts).with(selected_org_msg)

          assert_equal orgs.first, subject.org
        end
      end

      describe("when number of orgs > 1") do
        let(:orgs) { [new_org(1, "business1"), new_org(2, "business2")] }

        it("prompts to select an org") do
          CLI::UI::Prompt
            .expects(:ask)
            .with(context.message("script.application.ensure_env.organization_select"))
            .returns(orgs.last)

          assert_equal orgs.last, subject.org
        end
      end
    end
  end
end
