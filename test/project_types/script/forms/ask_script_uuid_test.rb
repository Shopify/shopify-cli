# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::Forms::AskScriptUuid do
  describe ".ask" do
    let(:context) { TestHelpers::FakeContext.new }
    let(:existing_scripts) { [] }

    subject do
      result = nil
      capture_io { result = Script::Forms::AskScriptUuid.ask(context, existing_scripts, {}) }
      result
    end

    describe("when asking script connection") do
      describe("when there are no scripts") do
        it("should abort") do
          context.expects(:puts).with(context.message("script.error.no_scripts_found_in_app"))
          subject
        end
      end

      describe("when a script exists") do
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

            assert_equal selected_uuid, subject.uuid
          end
        end

        describe("when user does not want to connect to script") do
          it("should not prompt the user to select a script") do
            CLI::UI::Prompt
              .expects(:confirm)
              .with(context.message("script.application.ensure_env.ask_connect_to_existing_script"))
              .returns(false)

            CLI::UI::Prompt
              .expects(:ask)
              .with(context.message("script.application.ensure_env.ask_which_script_to_connect_to"))
              .never

            assert_nil subject
          end
        end
      end
    end
  end
end
