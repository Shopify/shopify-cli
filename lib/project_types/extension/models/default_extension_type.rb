# frozen_string_literal: true
require 'base64'

module Extension
  module Models
    class DefaultExtensionType < Models::Type
      IDENTIFIER = :subscription_management

      def initialize(declaration)
        @type_declaration = declaration
      end

      def identifier
        @type_declaration.type
      end

      def name
        super || @type_declaration.name
      end

      def create(directory_name, context)
        context.abort('Unknown feature set') if @type_declaration.feature_argo_surface.nil?

        case @type_declaration.feature_argo_surface
        when :admin then Features::Argo::Admin.new.create(directory_name, template_identifier, context)
        when :checkout then Features::Argo::Checkout.new.create(directory_name, template_identifier, context)
        end
      end

      def config(context)
        context.abort('Unknown feature set') if @type_declaration.feature_argo_surface.nil?
        Features::Argo::Admin.new.config(context)
      end
    end
  end
end
