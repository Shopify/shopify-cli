module Extension
  module Models
    Specification = Struct.new(:identifier, keyword_init: true) do
      def handler_class_name
        identifier.split('_').map(&:capitalize).join
      end
    end
  end
end
