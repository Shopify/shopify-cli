# Shopify App CLI Development Guide

This document describes the architecture of the Shopify App CLI and some principles we adhered to when designing it. This is valuable context to have for anyone contributing to this project’s development.

## Principles

### Speed
The CLI should execute quickly, getting things done and returning to the prompt as soon as possible. In dealing with other languages and external services we may incur unavoidable latency, but the core execution and boot of the CLI should remain instantaneous.

### No dependencies
Because ruby objects are loaded into memory, the fewer runtime dependencies we `require` the better. We have only two depedencies: [cli-kit][cli-kit] and [cli-ui][cli-ui]. They are vendored in the codebase to avoid using bundler or sourcing gems, which can add latency.

### Don’t require escalated privileges
If possible don’t `sudo` or require passwords for any task. Most open-source tools avoid using escalated privileges. If they do, it’s usually left to the user to execute as a part of a specific action (`sudo make install`, for example). Adhering to this principle enforces trust, as developers are hesitant to use a tool that could do anything on their machine.

### Don’t call home without user’s permission
Similar to the previous point, developers are resistant to use developer tools that make network requests without their consent. We have implemented opt-in anonymized usage reporting so we can track the CLI’s most-used features and improve its stability and reliability.

### Don’t delete stuff
Any operation executed by the tool should be non-destructive. Leave it up to the user to remove things created by the tool if they wish.

### Separation of Concerns

Commands should deal with the user interface, options and arguments, serializing them as necessary, and calling Tasks to perform complex logic.
