Implementing a new project type
-------------------------------

Implementing a new project type is easy.

- First create a new folder `lib/project_types/<type name>`. This type name
  will setup how your project is loaded. For instance if you name your folder
  `foo`, it can be loaded by calling `ProjectType.load_type(:foo)`
- Inside your new project type create a cli.rb file with the following contents.

```ruby
# frozen_string_literal: true
module Foo
  class Project < ShopifyCli::ProjectType
    # hidden_project_type will hide this type from the create command so that users
    # wont discover it while you are developing it.
    hidden_project_type

    # creator defines the class to be loaded to create your app along with a title for it
    creator 'Foo App', 'Foo::Commands::Create'

    # register_command is used to define other commands on your project type.
    # This means providing the class to call, along with its calling name `shopify build`
    register_command('Foo::Commands::Build', "build")
  end

  # define/autoload project specific Commands
  # We leverage autoload so that we do not require all of our source code at startup.
  # if we required all of our files at startup, the cli would be slow
  module Commands
    # Project.project_filepath is used so that your filepaths will not break if
    # our setup changes. It defines the filepath, relative to your project type.
    autoload :Create, Project.project_filepath('commands/create')
    autoload :Build, Project.project_filepath('commands/build')
  end

  # define/autoload project specific Tasks
  module Tasks
  end

  # define/autoload project specific Forms
  module Forms
  end

  # define/autoload project specific service objects
  autoload :FooBulder, Project.project_filepath('foo_builder')
end
```

- Now you have defined a new project type. Please refer to Rails::Commands::Create
  for how to define a creator and commands.
