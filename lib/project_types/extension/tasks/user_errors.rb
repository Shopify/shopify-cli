# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    module UserErrors
      USER_ERRORS_FIELD = "userErrors"
      MESSAGE_FIELD = "message"
      USER_ERRORS_PARSE_ERROR = "Unable to parse errors from server."

      def abort_if_user_errors(context, response)
        return if response.nil?

        user_errors = response.dig(USER_ERRORS_FIELD)
        output_all_user_errors(context, user_errors)
      end

      private

      def output_all_user_errors(context, user_errors)
        return if user_errors.nil? || user_errors.empty?
        last_user_error = user_errors.pop

        user_errors.each { |user_error| puts_user_error(context, user_error) }
        abort_user_error(context, last_user_error)
      end

      def puts_user_error(context, user_error)
        output_user_error(context, user_error) { |message| context.puts("{{x}} #{message}") }
      end

      def abort_user_error(context, user_error)
        output_user_error(context, user_error) { |message| context.abort(message) }
      end

      def output_user_error(context, user_error)
        if user_error.key?(MESSAGE_FIELD)
          yield(user_error[MESSAGE_FIELD])
        else
          context.abort(USER_ERRORS_PARSE_ERROR)
        end
      end
    end
  end
end
