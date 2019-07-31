# Shopify App CLI design guidelines

The purpose of this doc is to outline all the heuristics, patterns, and templates we are using in the Shopify App CLI tool. All the content is based on the CLI Design and Style Guidelines doc, as well as the guidance on the Shopify cli-ui Github repo.

The most important principle to follow is **speed**. CLI tools are built to be extremely fast to use and to perform tasks quickly. If there is ever a collision between heuristics, default to whatever results in the fastest perceived or actual performance.

To help visualize all the components and states available in the Shopify App CLI, we have created a [UI Kit](https://www.figma.com/file/ZXIgM4wQpfRNjGaIArjWOgTD/CLI-UI-Kit?node-id=67%3A0) in [Figma](http://figma.com) that you can use to build command flows.

*Figma is a free web-based design tool.*

## Assumptions
The user understands the basic mechanics of a CLI:
- can type in commands to execute tasks
- there is a persistent “help” command that will educate them on specifics of each command/subcommand
- CTRL + C quits any running task
- how to navigate and manipulate the filesystem via the command line: cd and mkdir

## Design principles
High-level guiding principles to help make decisions faster when creating a CLI UI.

**Communicate every state (success, waiting, error) even if it’s redundant.**  

✅ Communicate task success even if the external process has also communicated success. Always wrap up what just happened with a success/error message.  
❌ Assume that success is understood because the process finished.

**Suppress output when the process is successful, and show output when the process has an error.**  

✅ Hide all STDOUT information if the process has run successfully, and show all output if the process failed.  
❌ Show every line or state if the process success/error state has not been determined yet.

**Error out if a task needs to make a system change and tell the user how to complete the installation.**  

✅ Prompt the user if you need to run something external that will modify their system to complete the installation.  
❌ Automatically install an NPM package that modifies the system. Prompt them that it’s needed and ask them if they would like the CLI to install it.

**If a process that fails early will affect the rest of the task, terminate it as soon as possible and tell the user why.**  

✅ Error out of a process if you know the rest of the task will fail.  
❌ Continue to try successfully completing the task if one crucial task failed.

**Output one idea per line.**  

✅ Error: you are not in an app project folder  
✅ Tip: use shopify create project to create a new app project  
❌ Error: you are not in an app project folder, use shopify create project to create a new app project.

**The command should ask for all the information needed to execute the task automatically.**  

✅ Have opinion on smart defaults that the user can override with arguments and options.  
❌ Defer multiple options or inputs to after the command is executing.

**Let the user opt in to verbosity.**  

✅ Show the user whatever is necessary given the task at hand. A summary may be best suited for tasks with many subprocesses, where some output might make sense for small tasks.  
❌ Show the user every bit of information that comes in from external or internal tasks.

## CLI UI states
Because of the serial nature of terminal input and output, CLIs have fewer states than graphical user interfaces. We provide design guidelines for three states:

**Input**  
The command a user types in to execute a task.  
`shopify create project projectName`

**Execute**  
While a task is running, the output from the task to communicate what is happening to the user.  
`Installing NPM...`  
`Updating files`  
`Checking dependencies`  

**Success/Error**  
Message at the end of the task executing to summarize what happened. This can be either a success or error message - because a CLI executes linearly, an error cannot happen inline or during a process, and the completion of a task will either end in success or error.  
`[success] Installed NPM in [directory]`  
`[error] NPM could not be installed because [output]`

## CLI commands
When contributing to the CLI consider the following commands and what their intents are before either adding new subcommands to them or creating new top-level commands.

### `Create`
Creating new parent resources that other commands depend on.

Subcommand:  
`project projectName`

Examples:  
`shopify create project myApp`  

### `Generate`
Generate is for creating new files and examples in the current app project.

Subcommand:  
`page`  
`webhook`  
`billing`  

Examples:  
`shopify generate page`

### `Populate`
Allows a user to add data to a development store.

Subcommands:  
`products`  
`customers`  
`draftorders`  

Options:  
`--count [integer]`  

Examples:  
`shopify populate products --count 100`

### `Serve`
Start an ngrok tunnel.

Example:  
`shopify serve`
