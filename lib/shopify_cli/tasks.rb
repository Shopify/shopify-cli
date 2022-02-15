require "shopify_cli"

module ShopifyCLI
  module Tasks
    class TaskRegistry
      def initialize
        @tasks = {}
      end

      def add(const, name)
        @tasks[name] = const
      end

      def [](name)
        class_or_proc = @tasks[name]
        if class_or_proc.is_a?(Class)
          class_or_proc
        elsif class_or_proc.respond_to?(:call)
          class_or_proc.call
        else
          class_or_proc
        end
      end
    end

    Registry = TaskRegistry.new

    def self.register(task, name, path = nil)
      autoload(task, path) if path
      Registry.add(-> () { const_get(task) }, name)
    end

    register :ConfirmStore, :confirm_store, "shopify_cli/tasks/confirm_store"
    register :CreateApiClient, :create_api_client, "shopify_cli/tasks/create_api_client"
    register :EnsureAuthenticated, :ensure_authenticated, "shopify_cli/tasks/ensure_authenticated"
    register :EnsureEnv, :ensure_env, "shopify_cli/tasks/ensure_env"
    register :EnsureGitDependency, :ensure_git_dependency, "shopify_cli/tasks/ensure_git_dependency"
    register :EnsureLoopbackURL, :ensure_loopback_url, "shopify_cli/tasks/ensure_loopback_url"
    register :EnsureProjectType, :ensure_project_type, "shopify_cli/tasks/ensure_project_type"
    register :EnsureDevStore, :ensure_dev_store, "shopify_cli/tasks/ensure_dev_store"
    register :SelectOrgAndShop, :select_org_and_shop, "shopify_cli/tasks/select_org_and_shop"
    register :UpdateDashboardURLS, :update_dashboard_urls, "shopify_cli/tasks/update_dashboard_urls"
  end
end
