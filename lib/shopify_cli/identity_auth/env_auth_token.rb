module ShopifyCLI
  class IdentityAuth
    class EnvAuthToken
      Token = Struct.new(:token, :expires_at, keyword_init: true)

      class << self
        attr_accessor :exchanged_partners_token

        def partners_token_present?
          Environment.auth_token
        end

        def fetch_exchanged_partners_token
          current_time = Time.now.to_i

          # If we have an in-memory token that hasn't expired yet, we reuse it.
          if exchanged_partners_token && current_time < exchanged_partners_token.expires_at.to_i
            return exchanged_partners_token.token
          end

          new_exchanged_token = yield(Environment.auth_token)
          token = new_exchanged_token["access_token"]
          expires_in = new_exchanged_token["expires_in"].to_i
          expires_at = Time.at(current_time + expires_in)

          token = Token.new(token: token, expires_at: expires_at)

          self.exchanged_partners_token = token
          token.token
        end
      end
    end
  end
end
