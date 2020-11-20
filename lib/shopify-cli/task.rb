require 'shopify_cli'

module ShopifyCli
  class Task
    def self.call(*args, **kwargs)
      task = new
      task.call(*args, **kwargs)
    end

    private

    def wants_to_run_against_shopify_org?
      @ctx.puts(@ctx.message('core.tasks.select_org_and_shop.identified_as_shopify'))
      message = @ctx.message('core.tasks.select_org_and_shop.first_party')
      CLI::UI::Prompt.confirm(message, default: false)
    end
  end
end
