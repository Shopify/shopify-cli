require 'shopify-cli'

Dir.glob('./lib/shopify-cli/app_types/*.rb') { |f| require f }

module ShopifyCli
  module AppTypes
  end
end
