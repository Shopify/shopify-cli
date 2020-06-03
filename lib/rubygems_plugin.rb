Gem.post_uninstall do |uninstaller|
  if uninstaller.spec.name == 'shopify-cli'
    require 'fileutils'

    symlink = '/usr/local/bin/shopify-cli'
    system("sudo rm -f #{symlink}") if File.symlink?(symlink)
  end

  true
end
