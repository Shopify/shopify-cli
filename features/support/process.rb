require "open3"

module Process
  def self.capture_shopify(*args)
    args = [shopify_executable_path] + args
    out, err, stat = Open3.capture3(*args)
    flunk(err) unless stat.success?
    out
  end

  def self.shopify_executable_path
    File.expand_path("../../bin/shopify", __dir__)
  end
end
