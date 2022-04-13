# This is a Docker image to test the CLI in UNIX environments other than macOS
# Build the image: docker build . -t shopify-cli
# Run tests: docker run -t --rm --volume "$(pwd):/usr/src/app" shopify-cli bundle exec rake test
FROM cimg/ruby:2.7.5

RUN git config --global user.email "development-lifecycle@shopify.com"
RUN git config --global user.name "Development Lifecycle"

RUN gem install bundler -v 2.3.11

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
COPY shopify-cli.gemspec  shopify-cli.gemspec
COPY lib/shopify_cli/version.rb  lib/shopify_cli/version.rb
RUN bundle install

# Update git
RUN sudo add-apt-repository -y ppa:git-core/ppa
RUN sudo apt-get update
RUN sudo apt-get install git -y

# Install the latest version of NodeJS
RUN sudo apt-get install ca-certificates -y
RUN curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

# Install the latest version of Yarn
RUN sudo npm install --global yarn

# Python is necessary to compile NPM packages with native extensions through node-gyp
RUN sudo apt install python2-minimal -y

# Install sqlite3
RUN sudo apt-get install libsqlite3-dev -y
