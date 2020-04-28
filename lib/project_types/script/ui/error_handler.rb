require 'cli/ui'

module Script
  module UI
    module ErrorHandler
      def self.display(failed_op:, cause_of_error:, help_suggestion:)
        $stderr.puts(CLI::UI.fmt("{{red:{{x}} Error}}"))
        full_msg = failed_op ? failed_op.dup : ""
        full_msg << " #{cause_of_error}" if cause_of_error
        full_msg << " #{help_suggestion}" if help_suggestion
        $stderr.puts(CLI::UI.fmt(full_msg.strip))
      end

      def self.display_and_raise(failed_op: nil, cause_of_error: nil, help_suggestion: nil)
        display(failed_op: failed_op, cause_of_error: cause_of_error, help_suggestion: help_suggestion)
        raise(ShopifyCli::AbortSilent)
      end

      def self.pretty_print_and_raise(e, failed_op: nil)
        messages = error_messages(e)
        raise e if messages.nil?
        display_and_raise(failed_op: failed_op, **messages)
      end

      def self.error_messages(e)
        case e
        when Errno::EACCES
          {
            cause_of_error: "You don't have permission to write to this directory.",
            help_suggestion: "Change your directory permissions and try again.",
          }
        when Errno::ENOSPC
          {
            cause_of_error: "You don't have enough disk space to perform this action.",
            help_suggestion: "Free up some space and try again.",
          }
        when ShopifyCli::OAuth::Error
          {
            cause_of_error: "Something went wrong while authenticating your account with the Partner Dashboard.",
            help_suggestion: "Try again.",
          }
        when DependencyInstallError
          {
            cause_of_error: "Something went wrong while installing the dependencies that are needed.",
            help_suggestion: "See https://help.shopify.com/en/",
          }
        when InvalidContextError
          {
            cause_of_error: "Your .shopify-cli.yml file is not correct.",
            help_suggestion: "See https://help.shopify.com/en/",
          }
        when InvalidExtensionPointError
          {
            cause_of_error: "Invalid extension point #{e.type}",
            help_suggestion: "Allowed values: discount and unit_limit_per_order.",
          }
        when ScriptNotFoundError
          {
            cause_of_error: "Couldn't find script #{e.script_name} for extension point #{e.extension_point_type}",
          }
        when ScriptProjectAlreadyExistsError
          {
            cause_of_error: "Directory with the same name as the script already exists.",
            help_suggestion: "Use different script name and try again.",
          }
        when TestError
          {
            help_suggestion: "Correct the errors and try again.",
          }
        end
      end
    end
  end
end
