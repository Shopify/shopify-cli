# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Forms::AskScriptUuid do
  include TestHelpers::FakeFS
  describe ".ask" do
    let(:context) { TestHelpers::FakeContext.new(root: Dir.mktmpdir) }
    let(:existing_scripts) { [] }

    subject do
      result = nil
      capture_io { result = Script::Forms::AskScriptUuid.ask(context, existing_scripts, {}) }
      result
    end

    describe("when asking script connection") do
      describe("when number of scripts == 0") do
        it("should not prompt the user to confirm if they want to replace existing scripts") do
          CLI::UI::Prompt.expects(:confirm).never
          CLI::UI::Prompt.expects(:ask).never
          subject
        end
      end

      describe("when number of scripts > 0") do
        let(:new_script_uuid) { "new_script_uuid" }
        let(:existing_scripts) { [{ "title" => "script_title", "uuid" => new_script_uuid }] }

        describe("when user wants to connect to script") do
          let(:selected_uuid) { new_script_uuid }

          it("should prompt the user to connect to script") do
            CLI::UI::Prompt
              .expects(:confirm)
              .with(context.message("script.application.ensure_env.ask_connect_to_existing_script"))
              .returns(true)

            CLI::UI::Prompt
              .expects(:ask)
              .with(context.message("script.application.ensure_env.ask_which_script_to_connect_to"))
              .returns(selected_uuid)

            subject
          end
        end

        describe("when user does not want to connect to script") do
          let(:selected_uuid) { nil }

          it("should not prompt the user to select a script") do
            CLI::UI::Prompt
              .expects(:confirm)
              .with(context.message("script.application.ensure_env.ask_connect_to_existing_script"))
              .returns(false)

            CLI::UI::Prompt
              .expects(:ask)
              .with(context.message("script.application.ensure_env.ask_which_script_to_connect_to"))
              .never

            subject
          end
        end
      end
    end
  end
end
