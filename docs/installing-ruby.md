# Installing Ruby

## Mac OS

We recommend using [`ruby-install`][ruby-install] and [`chruby`][chruby] from Homebrew to manage ruby versions.

1. Install [Homebrew][brew]
1. Install `ruby-install` and `chruby`. Be sure to follow the instructions for adding the chruby shell hook to your ~/.bash_profile or ~/.zshrc file.

        brew install ruby-install chruby

1. Install ruby 2.5.1:

        ruby-install ruby-2.5.1

1. Open a new terminal window and activate ruby 2.5.1:

        chruby ruby-2.5.1

1. Run your Shopify App CLI command.

## Linux

Ruby 2.5 is available for most recent versions of Ubuntu, including Trusty and Xenial, installable with `apt-get install ruby-2.5`. Look for it in your distributions package manager.

[brew]:https://brew.sh
[chruby]:https://github.com/postmodern/chruby
[ruby-install]:https://github.com/postmodern/ruby-install
