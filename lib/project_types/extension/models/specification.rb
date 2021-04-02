module Extension
  module Models
    class Specification
      include SmartProperties

      module Features
        class Argo
          include SmartProperties

          property! :surface, converts: :to_str
          property! :renderer_package_name, converts: :to_str
          property! :git_template, converts: :to_str
          property! :serve_requires_api_key, accepts: [true, false], default: false, reader: :serve_requires_api_key?
          property! :serve_requires_shop, accepts: [true, false], default: false, reader: :serve_requires_shop?
          property! :required_beta_flags, accepts: Array, default: -> { [] }
        end

        def self.build(feature_set_attributes)
          feature_set_attributes.each_with_object(OpenStruct.new) do |(identifier, feature_attributes), feature_set|
            feature_set[identifier] = ShopifyCli::ResolveConstant
              .call(identifier, namespace: Features)
              .rescue { OpenStruct }
              .then { |c| c.new(**feature_attributes) }
              .unwrap { |error| raise(error) }
          end
        end
      end

      property! :identifier
      property :name, converts: :to_str
      property :graphql_identifier, converts: :to_str
      property! :features, converts: Features.method(:build), default: -> { [] }
      property! :options, converts: ->(options) { OpenStruct.new(options) }, default: -> { OpenStruct.new }

      def graphql_identifier
        super || identifier
      end

      def feature?(name)
        !!features[name]
      end

      def required_beta_flags
        features.to_h.reduce([]) do |betas, (_, feature)|
          betas + (feature.required_beta_flags || [])
        end
      end
    end
  end
end
