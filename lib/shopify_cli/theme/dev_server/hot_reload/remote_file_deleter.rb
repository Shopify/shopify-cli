# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class DevServer
      class HotReload
        class RemoteFileDeleter
          def initialize(ctx, theme:, streams:)
            @ctx = ctx
            @theme = theme
            @streams = streams
          end

          def delete(file)
            retries = 6

            until retries.zero?
              retries -= 1

              _status, body = fetch_asset(file)
              retries = 0 if deleted_file?(body)

              wait
            end

            notify(file)
          end

          private

          def api_client
            @api_client ||= ThemeAdminAPI.new(@ctx, @theme.shop)
          end

          def deleted_file?(body)
            remote_checksum = body.dig("asset", "checksum")

            remote_checksum.nil?
          end

          def notify(file)
            @streams.broadcast(JSON.generate(deleted: [file]))
            @ctx.debug("[RemoteFileDeleter] Deleted #{file}")
          end

          def wait
            sleep(1)
          end

          def fetch_asset(file)
            api_client.get(
              path: "themes/#{@theme.id}/assets.json",
              query: URI.encode_www_form("asset[key]" => file.relative_path),
            )
          rescue ShopifyCLI::API::APIRequestNotFoundError
            [404, {}]
          end
        end
      end
    end
  end
end
