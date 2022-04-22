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

        def fetch_all_with_apps(ctx)
          resp = PartnersAPI.query(ctx, "all_orgs_with_apps")
          (resp&.dig("data", "organizations", "nodes") || []).map do |org|
            org["stores"] = (org.dig("stores", "nodes") || [])
            org["apps"] = (org.dig("apps", "nodes") || [])
            org
          end
        end

        def fetch_with_apps(ctx, id:)
          resp = PartnersAPI.query(ctx, "find_organization_with_apps", id: id)
          organization = resp&.dig("data", "organizations", "nodes")&.first
          return unless organization

          organization.tap { organization["apps"] = (organization.dig("apps", "nodes") || []) }
        end

        def fetch_with_extensions(ctx, type, id:)
          organization = fetch_with_apps(ctx, id: id)
          AppExtensions.fetch_apps_extensions(ctx, organization, type)
        end
      end
    end
  end
end
