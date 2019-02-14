require 'shopify_cli'

Dir.glob(
  File.join(ShopifyCli::ROOT, './lib/shopify-cli/app_types/*.rb')
) { |f| require f }

module ShopifyCli
  module AppTypes
  end
end
