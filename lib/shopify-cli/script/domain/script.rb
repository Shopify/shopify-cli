# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class Script
        attr_reader :name, :extension_point_type, :language

        def initialize(name, extension_point_type, language)
          @name = name
          @extension_point_type = extension_point_type
          @language = language
        end

        def id
          "#{extension_point_type}/#{filename}"
        end

        def filename
          "#{name}.#{language}"
        end
      end
    end
  end
end
