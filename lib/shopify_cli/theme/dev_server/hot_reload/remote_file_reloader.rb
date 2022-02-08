# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class HotReload
        class RemoteFileReloader
          def initialize(ctx, theme:, streams:)
            @ctx = ctx
            @theme = theme
            @streams = streams
          end

          def reload(file)
            retries = 6

            until retries.zero?
              retries -= 1

              _status, body = fetch_asset(file)
              retries = 0 if updated_file?(body, file)

              wait
            end

            notify(file)
          end

          private

          def updated_file?(body, file)
            remote_checksum = body.dig("asset", "checksum")
            local_checksum = file.checksum

            remote_checksum == local_checksum
          end

          def notify(file)
            @streams.broadcast(JSON.generate(modified: [file]))
            @ctx.debug("[RemoteFileReloader] Modified #{file}")
          end

          def wait
            sleep(1)
          end

          def fetch_asset(file)
            ShopifyCLI::AdminAPI.rest_request(
              @ctx,
              shop: @theme.shop,
              path: "themes/#{@theme.id}/assets.json",
              method: "GET",
              api_version: "unstable",
              query: URI.encode_www_form("asset[key]" => file.relative_path.to_s),
            )
          rescue ShopifyCLI::API::APIRequestNotFoundError
            [404, {}]
          end
        end
      end
    end
  end
end
