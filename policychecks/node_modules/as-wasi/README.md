# as-wasi

<!--- Badges -->

![npm version](https://img.shields.io/npm/v/as-wasi.svg)
![npm downloads per month](https://img.shields.io/npm/dm/as-wasi.svg)
![GitHub License](https://img.shields.io/github/license/torch2424/as-wasi.svg)

<!--- Short Description-->

A high-level AssemblyScript layer for the WebAssembly System Interface (WASI). 🧩

[WASI](https://wasi.dev) is an API providing access to the external world to WebAssembly modules. AssemblyScript exposes the low-level WASI standard set of system calls. `as-wasi` builds a higher level API on top of the AssemblyScript WASI interface, at a similar level to the [Node API](https://nodejs.org/docs/latest/api/). 🚀

## Installation

You can install `as-wasi` in your project by running the following:

`npm install --save as-wasi`

## Quick Start

Example usage of the `Console` and `Environ` classes:

```typescript
import "wasi";

// Import from the installed as-wasi package
import { Console, Environ } from "as-wasi";

// Create an envrion instance
let env = new Environ();

// Get the HOME Environment variable
let home = env.get("HOME")!;

// Log the HOME string to stdout
Console.log(home);
```

Here are some exported classes that are commonly used:

* `FileSystem` - Reading and Writing the user's fileystem. 📁
* `Console` - General logging to stdout and stderr. 🖥️
* `Environ` - Accessing environment variables, command flags, etc... 🌐
* `Date` - Getting the current system time. 📅
* `Random` - Accessing random numbers. 🤔
* `Time` - Allow sleeping and waiting for events to occur. ⏰
* And More! See the Reference API in the next section for the full API.

## Reference API Docs

Reference API documentation can be found in [REFERENCE_API_DOCS](./REFERENCE_API_DOCS.md). Documentation is generated using [typedoc](https://typedoc.org/).

## Projects using as-wasi

* [wasmboy](https://github.com/torch2424/wasmboy) - Game Boy / Game Boy Color Emulator Library, 🎮written for WebAssembly using AssemblyScript. 🚀
* [wasmerio/io-devices-lib](https://github.com/wasmerio/io-devices-lib) - Library for interacting with the Wasmer Experimental IO Devices API. Uses WASI for outputting graphics in a framebuffer, and handles mouse/keyboard input.
* [wasm-by-example](https://github.com/torch2424/wasm-by-example) - Wasm By Example is a website with a set of hands-on introduction examples and tutorials for WebAssembly (Wasm). Wasm By Example features `as-wasi` by default for the AssemblyScript WASI examples.
* [wasm-matrix](https://github.com/torch2424/wasm-matrix) - A Matrix effect in your terminal using AssemblyScript 🚀 and WASI 🧩 . THhise project is a bit older, and uses an older version of `as-wasi`, but still creates a cool effect!

_If you're project is using as-wasi, and you would like to be featured here. Please open a README with links to your project, and if appropriate, explaining how as-wasi is being used._ 😊

## Contributing

Contributions are definitely welcome! Feel free to open a PR for small fixes such as typos and things. Larger fixes, or new features should start out as an issue for discussion, in which then a PR should be made. 🥳

This project will also adhere to the [AssemblyScript Code of Conduct](https://github.com/AssemblyScript/assemblyscript/blob/master/CODE_OF_CONDUCT.md).

## License

[MIT](https://oss.ninja/mit/jesdict1). 📝
