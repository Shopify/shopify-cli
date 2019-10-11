module ShopifyCli
  module Helpers
    class Organizations
      class << self
        def fetch_all(ctx)
          resp = Helpers::PartnersAPI.query(ctx, 'all_organizations')
          resp['data']['organizations']['nodes'].map do |org|
            org['stores'] = org['stores']['nodes']
            org
          end
        end

        def fetch(ctx, id:)
          resp = Helpers::PartnersAPI.query(ctx, 'find_organization', id: id)
          org = resp['data']['organizations']['nodes'].first
          return nil if org.nil?
          org['stores'] = org['stores']['nodes']
          org
        end
      end
    end
  end
end
