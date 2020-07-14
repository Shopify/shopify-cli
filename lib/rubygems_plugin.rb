Gem.post_uninstall do |uninstaller|
  if uninstaller.spec.name == 'shopify-cli'
    require 'fileutils'

    symlink = '/usr/local/bin/shopify'

    # delete the symbolic link IFF it exists AND it does not point to a file
    # (i.e., it's been left hanging as a result of the uninstall, as expected)
    #
    # if the file still exists, either the uninstall failed (possible but
    # unlikely) OR
    # there's another installation of the gem in another ruby folder that has
    # overwritten it, so leave the symbolic link alone
    system("sudo rm -f #{symlink}") if File.symlink?(symlink) && !File.exist?(symlink)
  end

  true
end
