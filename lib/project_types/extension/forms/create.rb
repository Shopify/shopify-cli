# frozen_string_literal: true

module Extension
  module Forms
    class Create < ShopifyCLI::Form
      flag_arguments :name, :type, :api_key, :template

      attr_reader :app

      class ExtensionProjectDetails
        include SmartProperties

        property :app, accepts: Models::App
        property :name, accepts: String
        property :type, accepts: Models::SpecificationHandlers::Default
        property :template, accepts: String

        def complete?
          !!(app && name && type)
        end
      end

      def ask
        ShopifyCLI::Result.wrap(ExtensionProjectDetails.new)
          .then(&Questions::AskApp.new(ctx: ctx, api_key: api_key))
          .then(&Questions::AskType.new(ctx: ctx, type: type))
          .then(&Questions::AskTemplate.new(ctx: ctx, template: template))
          .then(&Questions::AskName.new(ctx: ctx, name: name))
          .unwrap { |e| raise e }
          .tap do |project_details|
            ctx.abort(ctx.message("create.incomplete_configuration")) unless project_details.complete?

            self.app = project_details.app
            self.type = project_details.type
            self.template = project_details.template
            self.name = project_details.name
          end
      end

      def directory_name
        name.strip.gsub(/( )/, "_").downcase
      end

      private

      attr_writer :app
    end
  end
end
