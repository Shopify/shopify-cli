# frozen_string_literal: true

module ShopifyCli
  module ScriptModule
    module Domain
      class Script
        attr_reader :name, :extension_point, :language

        def initialize(name, extension_point, language)
          @name = name
          @extension_point = extension_point
          @language = language
        end

        def id
          "#{extension_point.type}/#{filename}"
        end

        def filename
          "#{name}.#{language}"
        end
      end
    end
  end
end
