module ShopifyCLI
  class PartnersAPI
    class Organizations
      class << self
        def fetch_all(ctx)
          resp = PartnersAPI.query(ctx, "all_organizations")
          (resp&.dig("data", "organizations", "nodes") || []).map do |org|
            org["stores"] = (org.dig("stores", "nodes") || [])
            org
          end
        end

        def fetch(ctx, id:)
          resp = PartnersAPI.query(ctx, "find_organization", id: id)
          org = resp&.dig("data", "organizations", "nodes")&.first
          return nil if org.nil?
          org["stores"] = (org.dig("stores", "nodes") || [])
          org
        end

        def fetch_with_app(ctx)
          resp = PartnersAPI.query(ctx, "all_orgs_with_apps")
          (resp&.dig("data", "organizations", "nodes") || []).map do |org|
            org["stores"] = (org.dig("stores", "nodes") || [])
            org["apps"] = (org.dig("apps", "nodes") || [])
            org
          end
        end

        def fetch_with_extensions(ctx, type)
          orgs = fetch_with_app(ctx)
          patch_apps(ctx, orgs, type)
        end

        private

        def patch_apps(ctx, orgs, type)
          threads = []

          orgs.each do |org|
            org["apps"].each do |app|
              threads << Thread.new { patch_app(ctx, app, type) }
            end
          end

          threads.each { |thread| thread.join if thread.alive? }
          orgs
        end

        def patch_app(ctx, app, type)
          app.merge!(fetch_extension_registrations(ctx, app["apiKey"], type))
        end

        def fetch_extension_registrations(ctx, api_key, type)
          resp = PartnersAPI.query(ctx, "get_extension_registrations", api_key: api_key, type: type)
          resp&.dig("data", "app") || {}
        end
      end
    end
  end
end
