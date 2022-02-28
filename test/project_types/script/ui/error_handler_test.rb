# frozen_string_literal: true

require "project_types/script/test_helper"

describe Script::UI::ErrorHandler do
  describe ".display_and_raise" do
    let(:failed_op) { "Operation didn't complete." }
    let(:cause_of_error) { "This is why it failed." }
    let(:help_suggestion) { "Perhaps this is what's wrong." }

    subject do
      Script::UI::ErrorHandler.display_and_raise(
        failed_op: failed_op, cause_of_error: cause_of_error, help_suggestion: help_suggestion
      )
    end

    describe "when failed operation message, cause of error, and help suggestion are all provided" do
      describe "when failed operation message and cause of error end with whitespace" do
        let(:failed_op) { "Operation didn't complete. " }
        let(:cause_of_error) { "This is why it failed.\n" }
        it "should abort with the cause of error and help suggestion" do
          assert_silent_abort_and_stderr("✗ Error\n#{failed_op}#{cause_of_error}#{help_suggestion}\n") { subject }
        end
      end

      describe "when failed operation message and cause of error do not end with whitespace" do
        it "should abort with the cause of error and help suggestion" do
          assert_silent_abort_and_stderr("✗ Error\n#{failed_op} #{cause_of_error} #{help_suggestion}\n") { subject }
        end
      end
    end

    describe "when failed operation message is missing" do
      let(:failed_op) { nil }
      it "should abort with the cause of error and help suggestion" do
        assert_silent_abort_and_stderr("✗ Error\n#{cause_of_error} #{help_suggestion}\n") { subject }
      end
    end

    describe "when cause of error is missing" do
      let(:cause_of_error) { nil }
      it "should abort with the failed operation message and help suggestion" do
        assert_silent_abort_and_stderr("✗ Error\n#{failed_op} #{help_suggestion}\n") { subject }
      end
    end

    describe "when help suggestion is missing" do
      let(:help_suggestion) { nil }
      it "should abort with the failed operation message and cause of error" do
        assert_silent_abort_and_stderr("✗ Error\n#{failed_op} #{cause_of_error}\n") { subject }
      end
    end

    private

    def assert_silent_abort_and_stderr(expected_err)
      out, err = capture_io(strip_ansi: true) do
        assert_raises(ShopifyCLI::AbortSilent) { yield }
      end
      assert_empty(out)
      assert_equal(expected_err, err)
    end
  end

  describe ".pretty_print_and_raise" do
    let(:err) { nil }
    let(:failed_op) { "message" }
    subject { Script::UI::ErrorHandler.pretty_print_and_raise(err, failed_op: failed_op) }

    describe "when exception is not in list" do
      let(:err) { StandardError.new }

      it "should raise" do
        assert_raises(StandardError) { subject }
      end
    end

    describe "when exception is listed" do
      def should_call_display_and_raise
        Script::UI::ErrorHandler.expects(:display_and_raise).once
        subject
      end

      describe "when Errno::EACCESS" do
        let(:err) { Errno::EACCES.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when Errno::ENOSPC" do
        let(:err) { Errno::ENOSPC.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when Oauth::Error" do
        let(:err) { ShopifyCLI::IdentityAuth::Error.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when InvalidContextError" do
        let(:err) { Script::Layers::Infrastructure::Errors::InvalidContextError.new("") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when InvalidScriptTitleError" do
        let(:err) { Script::Errors::InvalidScriptTitleError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when NoExistingAppsError" do
        let(:err) { Script::Errors::NoExistingAppsError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when NoExistingOrganizationsError" do
        let(:err) { Script::Errors::NoExistingOrganizationsError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptProjectAlreadyExistsError" do
        let(:err) { Script::Layers::Infrastructure::Errors::ScriptProjectAlreadyExistsError.new("/") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when InvalidEnvironmentError" do
        let(:err) do
          Script::Layers::Infrastructure::Errors::InvalidEnvironmentError.new(
            "node",
            ::Semantic::Version.new("14.15.0"),
            "1.0.0",
          )
        end

        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when InvalidLanguageError" do
        let(:err) { Script::Layers::Infrastructure::Errors::InvalidLanguageError.new("ruby", "payment_methods") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when MetadataValidationError" do
        let(:err) { Script::Layers::Domain::Errors::MetadataValidationError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when MetadataNotFoundError" do
        let(:err) { Script::Layers::Domain::Errors::MetadataNotFoundError.new("filename") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptConfigParseError" do
        let(:err) do
          Script::Layers::Infrastructure::Errors::ScriptConfigParseError.new(
            filename: "filename",
            serialization_format: "serialization_format",
          )
        end
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when MissingScriptConfigFieldError" do
        let(:err) do
          Script::Layers::Domain::Errors::MissingScriptConfigFieldError.new(
            field: "field",
            filename: "filename",
          )
        end
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when NoScriptConfigFileError" do
        let(:err) { Script::Layers::Infrastructure::Errors::NoScriptConfigFileError.new("filename") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when InvalidExtensionPointError" do
        let(:err) { Script::Layers::Domain::Errors::InvalidExtensionPointError.new("") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end

        it "should not display deprecated or beta APIs" do
          expected_types = %w(payment_methods shipping_methods)
          Script::Layers::Application::ExtensionPoints.expects(:available_types).returns(expected_types)
          io = capture_io_and_assert_raises(ShopifyCLI::AbortSilent) { subject }
          assert_match(expected_types.join(", "), io.join)
        end
      end

      describe "when DeprecatedEPError" do
        let(:err) { Script::Layers::Infrastructure::Errors::DeprecatedEPError.new("some_api") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptNotFoundError" do
        let(:err) { Script::Layers::Domain::Errors::ScriptNotFoundError.new("ep type", "name") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when BuildError" do
        let(:err) { Script::Layers::Infrastructure::Errors::BuildError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptConfigurationDefinitionError" do
        let(:err) do
          Script::Layers::Infrastructure::Errors::ScriptConfigurationDefinitionError.new(
            messages: messages,
            filename: "filename",
          )
        end

        describe "when there is a single error message" do
          let(:messages) { ["message"] }
          it "should call display_and_raise" do
            should_call_display_and_raise
          end
        end

        describe "when there are multiple error messages" do
          let(:messages) { ["message1", "message2"] }
          it "should call display_and_raise" do
            should_call_display_and_raise
          end
        end
      end

      describe "when ScriptConfigSyntaxError" do
        let(:err) { Script::Layers::Infrastructure::Errors::ScriptConfigSyntaxError.new("filename") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptEnvAppNotConnectedError" do
        let(:err) { Script::Layers::Infrastructure::Errors::ScriptEnvAppNotConnectedError.new("filename") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptConfigMissingKeysError" do
        let(:err) do
          Script::Layers::Infrastructure::Errors::ScriptConfigMissingKeysError.new(
            missing_keys: "keys",
            filename: "filename",
          )
        end
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptConfigInvalidValueError" do
        let(:err) do
          Script::Layers::Infrastructure::Errors::ScriptConfigInvalidValueError.new(
            valid_input_modes: "input modes",
            filename: "filename",
          )
        end
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptConfigFieldsMissingKeysError" do
        let(:err) do
          Script::Layers::Infrastructure::Errors::ScriptConfigFieldsMissingKeysError.new(
            missing_keys: "keys",
            filename: "filename",
          )
        end
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptConfigFieldsInvalidValueError" do
        let(:err) do
          Script::Layers::Infrastructure::Errors::ScriptConfigFieldsInvalidValueError.new(
            valid_types: "types",
            filename: "filename",
          )
        end
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when DependencyInstallError" do
        let(:err) { Script::Layers::Infrastructure::Errors::DependencyInstallError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when EmptyResponseError" do
        let(:err) { Script::Layers::Infrastructure::Errors::EmptyResponseError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ForbiddenError" do
        let(:err) { Script::Layers::Infrastructure::Errors::ForbiddenError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when GraphqlError" do
        let(:err) { Script::Layers::Infrastructure::Errors::GraphqlError.new([]) }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when SystemCallFailureError" do
        let(:err) { Script::Layers::Infrastructure::Errors::SystemCallFailureError.new(out: "out", cmd: "cmd") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptRepushError" do
        let(:err) { Script::Layers::Infrastructure::Errors::ScriptRepushError.new("uuid") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when BuildScriptNotFoundError" do
        let(:err) { Script::Layers::Infrastructure::Errors::BuildScriptNotFoundError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when WebAssemblyBinaryNotFoundError" do
        let(:err) { Script::Layers::Infrastructure::Errors::WebAssemblyBinaryNotFoundError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ProjectConfigNotFoundError" do
        let(:err) { Script::Layers::Infrastructure::Errors::ProjectConfigNotFoundError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when InvalidProjectConfigError" do
        let(:err) { Script::Layers::Infrastructure::Errors::InvalidProjectConfigError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptUploadError" do
        let(:err) { Script::Layers::Infrastructure::Errors::ScriptUploadError.new }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when ScriptTooLargeError" do
        let(:err) { Script::Layers::Infrastructure::Errors::ScriptTooLargeError.new(max_size: "10") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when APILibraryNotFoundError" do
        let(:err) { Script::Layers::Infrastructure::Errors::APILibraryNotFoundError.new(library_name: "library") }
        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end

      describe "when LanguageLibraryForAPINotFoundError" do
        let(:err) do
          Script::Layers::Infrastructure::Errors::LanguageLibraryForAPINotFoundError.new(
            language: "lang",
            api: "api"
          )
        end

        it "should call display_and_raise" do
          should_call_display_and_raise
        end
      end
    end
  end
end
