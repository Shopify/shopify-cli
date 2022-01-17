
module Script
  module Layers
    module Infrastructure
      class MetadataRepository
        include SmartProperties
        property! :ctx, accepts: ShopifyCLI::Context

        def get_metadata(file_location)
          raise Domain::Errors::MetadataNotFoundError, file_location unless ctx.file_exist?(file_location)

          raw_contents = File.read(file_location)
          Domain::Metadata.create_from_json(ctx, raw_contents)
        end
      end
    end
  end
end
