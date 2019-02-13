# frozen_string_literal: true
module ShopifyCli
  module Helpers
    class API
      class Partners < API
        CLIENT_TOKEN = 'VKrE7ukJ1yHGGK21MGwhoZD9'
        CHECK_URI = "https://partners.myshopify.io/auth/cli/check"
        GENERATE_URI = "https://partners.myshopify.io/auth/cli/generate?client_id=#{CLIENT_TOKEN}&description=Shopify%20Command%20Line%20Interface"

        def initialize(ctx)
          super(ctx)
          if File.exist?(token_file)
            if authorized?
              token
            else
              clear_token
              write_token(fetch_token)
            end
          else
            write_token(fetch_token)
          end
          log(token)
        end

        def token
          @token ||= JSON.parse(File.read(token_file))
        end

        def fetch_token
          _, resp = get(GENERATE_URI)
          @code = resp['code']
          @secret = resp['secret']
          @authorize_url = resp['authorize_url']
          @verify_url = resp['verify_url']
          CLI::Kit::System.system('open', @authorize_url)
          while !@authorized
            pause
            begin
              _, resp = get(@verify_url)
            rescue APIRequestUnauthorizedError
              log "Error"
            end
            @authorized = true if resp['api_token']
          end
          resp['api_token']
        end

        def token_file
          File.join(ShopifyCli::ROOT, '.auth')
        end

        def write_token(token)
          json = {
            token: token,
            org: 1
          }
          File.write(token_file, JSON.dump(json))
          json
        end

        def clear_token
          FileUtils.rm(token_file)
          @token = nil
        end

        def get_apps
          query = <<~QUERY
            query {
              currentOrganization {
                apps {
                  title
                  apiKey
                  sharedSecret
                }
              }
            }
          QUERY
          _, resp = post(
            graph_url(token['org']), query_body(query), authorization: token['token']
          )
          apps = resp['data']['currentOrganization']['apps']
          apps.is_a?(Array) ? apps : [apps]
        end

        def update_app_url(id, url, callback_url)
          mutation = <<~QUERY
            mutation {
              updateAppUrl(input: {
                apiKey: "#{id}",
                url: "#{url}",
                callbackUrl: "#{callback_url}"
              }) {
                url
                callbackUrls
              }
            }
          QUERY
          _, resp = post(
            graph_url(token['org']), query_body(mutation), authorization: token['token']
          )
          log resp
        end

        def query_body(query, variables: {})
          JSON.dump({
            query: query,
            variables: variables
          })
        end

        def graph_url(organization_id)
          "https://partners.myshopify.io/api/internal/graphql/#{organization_id}"
        end

        def authorized?
          begin
            _, resp = get(CHECK_URI, authorization: token['token'])
          rescue APIRequestUnauthorizedError => e
            log(e)
          end
        end
      end
    end
  end
end
