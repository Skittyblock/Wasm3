# Wasm3

A wasm3 wrapper for Swift. Design is based on [wasm3-rs](https://github.com/wasm3/wasm3-rs).

## Why use wasm3 in Swift?

WebAssembly is an appealing solution for things like plugins that can add additional functionality to apps on the fly. The ability to compile from multiple languages, particularly Rust, is a benefit over using JavaScript. Unfortunately, the WebAssembly API is disabled in JavaScriptCore on iOS, and the App Store has restrictions regarding JIT usage (which rules out stuff like wasmer and wasmtime), so to use WebAssembly on iOS we're required to interpret it. The best solution for this is wasm3, which is a very fast interpreter.

Wasm3 is currently used in [Aidoku](https://github.com/Aidoku/Aidoku) for sources.
