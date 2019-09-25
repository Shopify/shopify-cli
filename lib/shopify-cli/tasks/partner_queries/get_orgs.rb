module ShopifyCli
  module Tasks
    class GetOrgs < ShopifyCli::Task
      def call(ctx)
        @ctx = ctx
        data = ShopifyCli::Helpers::PartnersAPI.query(
          @ctx, query(Project.current.env.api_key)
        )
        result = data['data']['organizations']['edges']
        list = result.map { |r| { r['node']['businessName'] => r['node']['id'] } }
        orgs = list.inject(:merge)
        org = CLI::UI::Prompt.ask('Which organization would you like to use') do |handler|
          orgs.each do |key, value|
            handler.option(key) { value }
          end
        end
        org
      end

      def query
        <<~QUERY
          query getOrgs {
            organizations {
              edges {
                  node {
                      id
                      businessName
                    }
                }
            }
          }
        QUERY
      end
    end
  end
end
