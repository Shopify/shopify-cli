# frozen_string_literal: true

module Extension
  module Forms
    class Connect < ShopifyCLI::Form
      attr_reader :registration, :app

      flag_arguments :type

      class ExtensionProjectDetails
        include SmartProperties

        property :registration, accepts: Models::Registration
        property :app, accepts: Models::App

        def complete?
          !!(registration && app)
        end
      end

      def ask
        ShopifyCLI::Result.wrap(ExtensionProjectDetails.new)
          .then(&Questions::AskRegistration.new(ctx: ctx, type: type))
          .unwrap { |e| raise e }
          .tap do |project_details|
            ctx.abort(ctx.message("connect.incomplete_configuration")) unless project_details.complete?

            self.registration = project_details.registration
            self.app = project_details.app
          end
      end

      def directory_name
        name.strip.gsub(/( )/, "_").downcase
      end

      private

      attr_writer :registration, :app
    end
  end
end
