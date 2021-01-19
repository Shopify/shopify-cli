# Extension Specifications

Extension specifications provide metadata about extensions and formally describe their feature set. The CLI uses this information to bootstrap projects and facilitate communication with the Partner Dashboard.

Introducing specifications results in a few changes to the CLI internals:

- Type declarations become specifications
- Types become specification handlers
- Communication with the partner dashboard in regards to extension specifications is extracted into a separate repository.
